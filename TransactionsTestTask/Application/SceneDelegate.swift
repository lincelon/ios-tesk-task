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
    private lazy var bitcoinRateUpdater: BicoinRateUdpdatable = BitcoinRateUdpdaterFacade(
        httpClient: httpClient,
        bitcoinRateStore: store,
        analyticsService: analyticsService
    )
    
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
        bitcoinRateUpdater.update()
    }
    
    func makeBalanceLoader() -> AnyPublisher<Balance, Error> {
        store.loadBalancePublisher()
    }
}
