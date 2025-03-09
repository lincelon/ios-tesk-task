//
//  CombineHelpers.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Combine
import Foundation

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
            receiveCompletion: {
                switch $0 {
                case .finished:
                    print("xxxx1")
                case let .failure(error):
                    print("xxxx2", error.localizedDescription)
                }
            },
            receiveCancel: { task?.cancel() }
        )
        .eraseToAnyPublisher()
    }
}

extension BitcoinRateStore {
    typealias Publisher = AnyPublisher<BitcoinRate, Error>
    
    func loadPublisher() -> Publisher {
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

extension TransactionsStore {
    typealias Publisher = AnyPublisher<[Transaction], Error>
    
    func loadPublisher() -> Publisher {
        Deferred {
            Future { completion in
                completion(
                    Result {
                        try self.retrieve()
                    }
                )
            }
        }
        .eraseToAnyPublisher()
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
