//
//  CombineHelpers.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Combine
import Foundation

extension Paginated {
    init(
        items: [Item],
        loadMorePublisher: ((Int) -> AnyPublisher<Self, Error>)?
    ) {
        self.init(
            items: items,
            loadMore: loadMorePublisher.map { publisher in
                { offset, completion in
                    publisher(offset)
                        .subscribe(
                            Subscribers.Sink(
                                receiveCompletion: { result in
                                    if case let .failure(error) = result {
                                        completion(.failure(error))
                                    }
                                }, receiveValue: { result in
                                    completion(.success(result))
                                }
                            )
                        )
                }
            }
        )
    }
    
    var loadMorePublisher: ((Int) -> AnyPublisher<Self, Error>)? {
        guard let loadMore = loadMore else { return nil }
        
        return { offset in
            Deferred {
                Future { completion in
                    loadMore(offset, completion)
                }
            }
            .eraseToAnyPublisher()
        }
    }
}


extension HTTPClient {
    typealias Publisher = AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
    
    func getPublisher(url: URL) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { completion in
                task = get(from: url, completion: completion)
            }
        }
        .handleEvents(
            receiveCancel: { task?.cancel() }
        )
        .eraseToAnyPublisher()
    }
}

extension BitcoinRateStore {
    typealias Publisher = AnyPublisher<BitcoinRate, Error>
    
    func loadBitcoinRatePublisher() -> Publisher {
        Deferred {
            Future { completion in
                completion(
                    Result {
                        try self.retrieve() ?? .zero
                    }
                )
            }
        }
        .eraseToAnyPublisher()
    }
}

extension BalanceStore {
    typealias Publisher = AnyPublisher<Balance, Error>
    
    func loadBalancePublisher() -> Publisher {
        Deferred {
            Future { completion in
                completion(
                    Result {
                        try self.balance() ?? .zero
                    }
                )
            }
        }
        .eraseToAnyPublisher()
    }
}

extension LocalTransactionsLoader {
    typealias Publisher = AnyPublisher<(items: [Transaction], nextPage: Bool), Error>
    
    func loadTransactionsPublisher(offset: Int) -> Publisher {
        Deferred {
            Future { completion in
                completion(
                    Result {
                        try self.load(offset: offset)
                    }
                )
            }
        }
        .eraseToAnyPublisher()
    }
}

extension TransactionsStore {
    typealias Publisher = AnyPublisher<[Transaction], Error>
    
    func loadPublisher(offset: Int, limit: Int) -> Publisher {
        Deferred {
            Future { completion in
                completion(
                    Result {
                        try self.retrieve(offset: offset, limit: limit)
                    }
                )
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func track(in analyticsSetvice: AnalyticsService) -> AnyPublisher<Output, Failure> where Output == BitcoinRate {
        handleEvents(
            receiveOutput: { rate in
                analyticsSetvice.trackEvent(
                    name: "bitcoin-rate-update",
                    parameters: [
                        "rate": String(rate)
                    ]
                )
            }
        ).eraseToAnyPublisher()
    }
}

extension Publisher {
    func caching(to cache: TransactionsStore) -> AnyPublisher<Output, Failure> where Output == Transaction {
        handleEvents(
            receiveOutput: {
                try? cache.insert($0)
            }
        ).eraseToAnyPublisher()
    }
}

extension Publisher {
    func caching(to cache: BitcoinRateStore) -> AnyPublisher<Output, Failure> where Output == BitcoinRate {
        handleEvents(
            receiveOutput: {
                try? cache.save($0)
            }
        ).eraseToAnyPublisher()
    }
}

extension Publisher {
    func executePeriodically(every interval: TimeInterval, on runLoop: RunLoop = .current) -> AnyPublisher<Output, Failure> {
        Timer.publish(every: interval, on: runLoop, in: .common)
            .autoconnect()
            .merge(with: Just(Date.now))
            .flatMap(maxPublishers: .max(1)) { _ in
                self
            }
            .eraseToAnyPublisher()
    }
}
