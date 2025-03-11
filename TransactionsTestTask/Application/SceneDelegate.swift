//
//  SceneDelegate.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine
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
    
    private lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: makeTransactionsScene())
        return navigationController
    }()
    
    private let store: BitcoinRateStore & TransactionsStore & BalanceStore = {
        do {
            let storeURL = NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("obrio-store.sqlite")
            return try CoreDataTransactionsStore(
                storeURL: storeURL
            )
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var localTransactionsLoader = LocalTransactionsLoader(store: store)
    private lazy var analyticsService: AnalyticsService = AnalyticsServiceImp()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    func makeTransactionsScene() -> UIViewController {
        TransactionsUIComposer.compose(
            depoist: showDepositScene,
            addTransaction: showAddTransactionScene,
            bitcoinRateUpdater: makeBitcoinRateUpdater,
            transactionsLoader: makeTansactionsLoader,
            balanceLoader: makeBalanceLoader
        )
    }
    
    func showDepositScene() -> AnyPublisher<Transaction, Never> {
        let (controller, result) = DepositUIComposer.compose()
        navigationController.present(controller, animated: true)
        return result
            .caching(to: store)
            .eraseToAnyPublisher()
    }
    
    func showAddTransactionScene() -> AnyPublisher<Transaction, Never> {
        let (controller, result) = AddTransactionUIComposer.compose()
        navigationController.pushViewController(controller, animated: true)
        return result
            .caching(to: store)
            .handleEvents(
                receiveOutput: { [navigationController] _ in
                    navigationController.popViewController(animated: true)
                }
            )
            .eraseToAnyPublisher()
    }
    
    func makeTansactionsLoader(offset: Int = .zero) -> AnyPublisher<Paginated<Transaction>, Error> {
        localTransactionsLoader.loadTransactionsPublisher(offset: offset)
            .map(makePage)
            .eraseToAnyPublisher()
    }
    
    func makePage(items: [Transaction], nextPage: Bool) -> Paginated<Transaction> {
        Paginated(
            items: items,
            loadMorePublisher: nextPage ? { self.makeTansactionsLoader(offset: $0) } : nil
        )
    }
    
    func makeBitcoinRateUpdater() -> AnyPublisher<BitcoinRate, Error> {
        makeLocalBitcoinRateLoader()
            .merge(with: makeRemoteBitcoinRateLoader())
            .eraseToAnyPublisher()
    }
    
    func makeRemoteBitcoinRateLoader() -> AnyPublisher<BitcoinRate, Error> {
        let baseURL = URL(string: "https://api.coincap.io")!
        let url = TransactionsEndpoint.bitcoinRate.url(baseURL: baseURL)
        let twoMinutes: TimeInterval = 120
        return httpClient
            .getPublisher(url: url)
            .tryMap(BitcoinRateMapper.map)
            .caching(to: store)
            .track(in: analyticsService)
            .executePeriodically(every: twoMinutes)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeLocalBitcoinRateLoader() -> AnyPublisher<BitcoinRate, Error> {
        store.loadBitcoinRatePublisher()
    }
    
    func makeBalanceLoader() -> AnyPublisher<Balance, Error> {
        store.loadBalancePublisher()
    }
}
