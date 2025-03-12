//
//  BitcoinRateUpdaterFacadeTests.swift
//  TransactionsTestTaskTests
//
//  Created by Maksym Soroka on 11.03.2025.
//

import Foundation
import Combine
import XCTest
@testable import TransactionsTestTask

final class BitcoinRateUdpdaterFacadeTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        cancellables = []
    }
    
    func test_update_withLocalStoreValue_emitsLocalValueAndDoesNotTrackAnalytics() {
        let store = BitcoinRateStoreSpy()
        let storedRate = 90000.0
        store.storedRate = storedRate
        let analyticsService = AnalyticsServiceSpy()
        
        let sut = BitcoinRateUdpdaterFacade(
            httpClient: HTTPClientStub.offline,
            bitcoinRateStore: store,
            analyticsService: analyticsService
        )
        
        let expectation = expectation(description: "Emits local value")
        var receivedRates = [BitcoinRate]()
        
        sut.update()
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        XCTFail("Unexpected error: \(error)")
                    }
                },
                receiveValue: { rate in
                    receivedRates.append(rate)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(receivedRates.contains(storedRate))
        XCTAssertTrue(analyticsService.trackedEvents.isEmpty)
    }
    
    func test_update_withoutLocalStoreValue_emitsRemoteValueCachesAndTracksAnalytics() {
        let store = BitcoinRateStoreSpy()
        let fixedEventsDate = Date()
        let analyticsService = AnalyticsServiceSpy(fixedEventsDate: fixedEventsDate)
        let expectedRemoteRate: BitcoinRate = 90340.4
        let sut = BitcoinRateUdpdaterFacade(
            httpClient: HTTPClientStub.online { url in
                let dummyData = BitcoinRateMapper.makeJSONData(for: expectedRemoteRate)
                let dummyResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (dummyData, dummyResponse)
            },
            bitcoinRateStore: store,
            analyticsService: analyticsService
        )
        let emitValueExpectation = expectation(description: "Emits remote value")
        emitValueExpectation.expectedFulfillmentCount = 1
        var receivedRates = [BitcoinRate]()
        
        sut.update()
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        XCTFail("Unexpected error: \(error)")
                    }
                }, receiveValue: { rate in
                    receivedRates.append(rate)
                    emitValueExpectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [emitValueExpectation], timeout: 1.5)
        
        XCTAssertEqual(receivedRates.count, 1)

        let expectedEvent = AnalyticsEvent(
            name: "bitcoin-rate-update",
            parameters: [
                "rate": String(expectedRemoteRate)
            ],
            date: fixedEventsDate
        )
        
        XCTAssertTrue(receivedRates.contains(expectedRemoteRate))
        XCTAssertEqual(store.storedRate, expectedRemoteRate)
        XCTAssertTrue(analyticsService.trackedEvents.contains(where: { $0 == expectedEvent }))
      }
      
    func test_update_withLocalAndRemoteValues_emitsBoth() {
        let store = BitcoinRateStoreSpy()
        let expectedRemoteRate: BitcoinRate = 90340.4
        let expectedLocalRate: BitcoinRate = 94543.9
        store.storedRate = expectedLocalRate
        let analyticsService = AnalyticsServiceSpy()
        let sut = BitcoinRateUdpdaterFacade(
            httpClient: HTTPClientStub.online { url in
                let dummyData = BitcoinRateMapper.makeJSONData(for: expectedRemoteRate)
                let dummyResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (dummyData, dummyResponse)
            },
            bitcoinRateStore: store,
            analyticsService: analyticsService
        )
        
        var receivedRates = [BitcoinRate]()
        let expectation = expectation(description: "Emits both local and remote values")
        expectation.expectedFulfillmentCount = 2
        
        sut.update()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Unexpected error: \(error)")
                    }
                }, receiveValue: { rate in
                    receivedRates.append(rate)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(receivedRates.contains(expectedLocalRate))
        XCTAssertTrue(receivedRates.contains(expectedRemoteRate))
    }
    
    func test_update_periodically_emitsMultipleRemoteValuesCachesAndTracksAnalytics() {
        let expectedRemoteRate: BitcoinRate = 94543.9
        let fixedEventsDate = Date()
        let analyticsService = AnalyticsServiceSpy(fixedEventsDate: fixedEventsDate)
        let store = BitcoinRateStoreSpy()
        let updateInterval = 0.5
        let sut = BitcoinRateUdpdaterFacade(
            httpClient: HTTPClientStub.online { url in
                let dummyData = BitcoinRateMapper.makeJSONData(for: expectedRemoteRate)
                let dummyResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (dummyData, dummyResponse)
            },
            bitcoinRateStore: store,
            analyticsService: analyticsService,
            updateInterval: updateInterval
        )
        
        let expectedCallTimes = 3
        let timeout = updateInterval * Double(expectedCallTimes) + updateInterval
        let expectation = expectation(description: "Emits multiple remote values")
        expectation.expectedFulfillmentCount = expectedCallTimes
        
        var receivedRates = [BitcoinRate]()
        
        sut.update()
            .prefix(expectedCallTimes)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { rate in
                    receivedRates.append(rate)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: timeout)
    
        let expectedEvent = AnalyticsEvent(
            name: "bitcoin-rate-update",
            parameters: [
                "rate": String(expectedRemoteRate)
            ],
            date: fixedEventsDate
        )
        
        XCTAssertEqual(receivedRates, Array(repeating: expectedRemoteRate, count: expectedCallTimes))
        XCTAssertEqual(store.saveTimes, expectedCallTimes)
        XCTAssertEqual(analyticsService.trackedEvents.count, expectedCallTimes)
        XCTAssertTrue(analyticsService.trackedEvents.allSatisfy { $0 == expectedEvent })
    }
}
