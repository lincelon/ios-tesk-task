//
//  AnalyticsServiceTests.swift
//  AnalyticsServiceTests
//
//

import XCTest
@testable import TransactionsTestTask

final class AnalyticsServiceTests: XCTestCase {
    func test_trackEvent_addsEvent() {
        let sut = makeSUT()
        sut.trackEvent(name: "TestEvent", parameters: ["key": "value"])
        let events = sut.fetchEvents(using: [])
        
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.name, "TestEvent")
        XCTAssertEqual(events.first?.parameters["key"], "value")
    }
    
    func test_fetchEvents_noFilters_returnsAllEvents() {
        let sut = makeSUT()
        sut.trackEvent(name: "Event1", parameters: [:])
        sut.trackEvent(name: "Event2", parameters: [:])
        
        let events = sut.fetchEvents(using: [])
        XCTAssertEqual(events.count, 2)
    }
    
    func test_fetchEvents_correctlyFiltersNames() {
        let sut = makeSUT()
        sut.trackEvent(name: "Event1", parameters: [:])
        sut.trackEvent(name: "Event2", parameters: [:])
        sut.trackEvent(name: "Event1", parameters: [:])
        
        let filtered = sut.fetchEvents(using: [.name("Event1")])
        XCTAssertEqual(filtered.count, 2)
        filtered.forEach { event in
            XCTAssertEqual(event.name, "Event1")
        }
    }
    
    func test_fetchEvents_correctlyFiltersRanges() {
        let sut = makeSUT()
        sut.trackEvent(name: "Event1", parameters: [:])
        
        let initialEvents = sut.fetchEvents(using: [])
        guard let firstEventDate = initialEvents.first?.date else {
            XCTFail("Failed to get date from first event")
            return
        }
        
        let expectation = expectation(description: "Wait for a different event timestamp")
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            sut.trackEvent(name: "Event2", parameters: [:])
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2.0)
        
        let allEvents = sut.fetchEvents(using: [])
        XCTAssertEqual(allEvents.count, 2)
        
        let startDate = firstEventDate.addingTimeInterval(-0.5)
        let endDate = firstEventDate.addingTimeInterval(0.5)
        let filtered = sut.fetchEvents(using: [.range(startDate...endDate)])
        
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "Event1")
    }
    
    private func makeSUT() -> AnalyticsService {
        AnalyticsServiceImp()
    }
}
