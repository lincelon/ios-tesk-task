//
//  BitcoinRateUpdaterFacade.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 12.03.2025.
//

import Foundation
import Combine

protocol BicoinRateUdpdatable {
    func update() -> AnyPublisher<BitcoinRate, Error>
}

final class BitcoinRateUdpdaterFacade {
    private let httpClient: HTTPClient
    private let bitcoinRateStore: BitcoinRateStore
    private let analyticsService: AnalyticsService
    private let updateInterval: TimeInterval
    private let scheduler = DispatchQueue(
        label: "com.obrio.queue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    init(
        httpClient: HTTPClient,
        bitcoinRateStore: BitcoinRateStore,
        analyticsService: AnalyticsService,
        updateInterval: TimeInterval = 120
    ) {
        self.httpClient = httpClient
        self.bitcoinRateStore = bitcoinRateStore
        self.analyticsService = analyticsService
        self.updateInterval = updateInterval
    }
    
    private func makeRemoteBitcoinRateLoader() -> AnyPublisher<BitcoinRate, Error> {
        let baseURL = URL(string: "https://api.coincap.io")!
        let url = TransactionsEndpoint.bitcoinRate.url(baseURL: baseURL)
        return httpClient
            .getPublisher(url: url)
            .tryMap(BitcoinRateMapper.map)
            .caching(to: bitcoinRateStore)
            .track(in: analyticsService)
            .executePeriodically(every: updateInterval)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeLocalBitcoinRateLoader() -> AnyPublisher<BitcoinRate, Error> {
        bitcoinRateStore
            .loadBitcoinRatePublisher()
            .filter { $0 != .zero }
            .eraseToAnyPublisher()
    }
}

extension BitcoinRateUdpdaterFacade: BicoinRateUdpdatable {
    func update() -> AnyPublisher<BitcoinRate, Error> {
        makeLocalBitcoinRateLoader()
            .merge(with: makeRemoteBitcoinRateLoader())
            .eraseToAnyPublisher()
    }
}
