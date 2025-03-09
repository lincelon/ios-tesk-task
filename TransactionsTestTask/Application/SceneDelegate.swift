//
//  SceneDelegate.swift
//  TransactionsTestTask
//
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private let httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var scheduler = DispatchQueue(
        label: "com.obrio.queue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    private let store: BitcoinRateStore = {
        do {
            let storeURL = NSPersistentContainer
                .defaultDirectoryURL()
                   .appendingPathComponent("feed-store.sqlite")
            
            return try CoreDataTransactionsStore(
                storeURL: storeURL
            )
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
//    private lazy var localBitcoinRateLoader = LocalBitcoinRateLoader(store: store)
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TransactionsUIComposer.compose(
            bitcoinRateUpdater: makeBitcoinRateUpdater
        )
        window?.makeKeyAndVisible()
    }
    
    private func makeBitcoinRateUpdater() -> AnyPublisher<BitcoinRate, Error> {
        Publishers.Merge(
            makeLocalBitcoinRateLoader(),
            makeRemoteBitcoinRateLoader()
        )
        .eraseToAnyPublisher()
    }
    
    private func makeRemoteBitcoinRateLoader() -> AnyPublisher<BitcoinRate, Error> {
        let baseURL = URL(string: "https://api.coincap.io")!
        let url = TransactionsEndpoint.bitcoinRate.url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(BitcoinRateMapper.map)
            .caching(to: store)
            .executePeriodically(every: 30)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeLocalBitcoinRateLoader() -> AnyPublisher<BitcoinRate, Error> {
        store.loadPublisher()

    }
}

enum TransactionsUIComposer {
    static func compose(
        bitcoinRateUpdater: @escaping () -> AnyPublisher<BitcoinRate, Error>
    ) -> TransactionsViewController {
        let transactionPresentationAdapter = TransactionsPresentationAdapter(
            bitcoinRateUpdater: bitcoinRateUpdater
        )
        let controller = TransactionsViewController(
            delegate: transactionPresentationAdapter
        )
        let presenter = TransactionsPresenter(
            view: WeakRefVirtualProxy(controller)
        )
        transactionPresentationAdapter.presenter = presenter
        return controller
    }
}

import Combine

final class TransactionsPresentationAdapter: TransactionsViewControllerDelegate {
    var presenter: TransactionsPresenter?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        bitcoinRateUpdater: () -> AnyPublisher<Double, Error>
    ) {
        bitcoinRateUpdater()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [unowned self] in
                    if case let .failure(error) = $0 {
                        print(error)
                    }
                },
                receiveValue: { [unowned self] in
                    presenter?.didUpdateBitcounRate(rate: $0)
                }
            )
            .store(in: &cancellables)
    }
    
    func didTapAddTransactionButton() {
        
    }
    
    func didTapDepositButton() {
        
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
