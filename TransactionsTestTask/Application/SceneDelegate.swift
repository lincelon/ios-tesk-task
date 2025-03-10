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
    
    private lazy var navController: UINavigationController = {
        let navController = UINavigationController(rootViewController: makeTransactionsScene())
        return navController
    }()
    
    private let store: BitcoinRateStore & TransactionsStore = {
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
    
    private lazy var localTransactionsLoader = LocalTransactionsLoader(store: store)
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    func makeTransactionsScene() -> UIViewController {
        TransactionsUIComposer.compose(
            bitcoinRateUpdater: makeBitcoinRateUpdater,
            depoist: showDepositScene,
            transactionsLoader: makeTansactionsLoader
        )
    }
    
    func showDepositScene() -> AnyPublisher<Transaction, Never> {
        let (controller, result) = DepositUIComposer.compose()
        navController.present(controller, animated: true)
        return result
            .caching(to: store)
            .eraseToAnyPublisher()
    }
    
    func makeTansactionsLoader(offset: Int = .zero) -> AnyPublisher<Paginated<Transaction>, Error> {
        localTransactionsLoader.loadPublisher(offset: offset)
            .map { transactions, isThereNextPage in
                self.makePage(items: transactions, nextPage: isThereNextPage)
            }
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
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(BitcoinRateMapper.map)
            .caching(to: store)
            .executePeriodically(every: 30)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    func makeLocalBitcoinRateLoader() -> AnyPublisher<BitcoinRate, Error> {
        store.loadPublisher()
    }
}
