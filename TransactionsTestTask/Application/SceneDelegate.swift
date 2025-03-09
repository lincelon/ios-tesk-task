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
    
//    private lazy var localBitcoinRateLoader = LocalBitcoinRateLoader(store: store)
    
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
    
    private func makeTransactionsScene() -> UIViewController {
        TransactionsUIComposer.compose(
            bitcoinRateUpdater: makeBitcoinRateUpdater,
            depoist: showDepositScene,
            transactionsLoader: makeTansactionsLoader
        )
    }
    
    private func showDepositScene() -> AnyPublisher<Transaction, Never> {
        let (controller, result) = DepositUIComposer.compose()
        navController.present(controller, animated: true)
        return result
            .caching(to: store)
            .eraseToAnyPublisher()
    }
    
    private func makeTansactionsLoader() -> AnyPublisher<[Transaction], Error> {
        store.loadPublisher()
    }

    private func makeBitcoinRateUpdater() -> AnyPublisher<BitcoinRate, Error> {
        makeLocalBitcoinRateLoader()
            .merge(with: makeRemoteBitcoinRateLoader())
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

final class DepositPresentationAdapter {
    private let resultSubject = PassthroughSubject<Transaction, Never>()

    var result: AnyPublisher<Transaction, Never> {
        resultSubject.eraseToAnyPublisher()
    }
    
    func didRecieveDeposit(_ amount: String) {
        guard
            let amount = Double(amount),
            amount > 0
        else { return }
        let transaction = DepositPresenter.map(amount)
        resultSubject.send(transaction)
    }
}

enum DepositUIComposer {
    static func compose() -> (controller: UIAlertController, result: AnyPublisher<Transaction, Never>) {
        let presentationAdapter = DepositPresentationAdapter()
        let controller = UIAlertController.withTextField(
            title: DepositPresenter.title,
            message: DepositPresenter.message,
            placeholder: DepositPresenter.placeholder,
            cancelTitle: DepositPresenter.cancelButtonTitle,
            cancelAction: { },
            primaryTitle: DepositPresenter.receiveButtonTitle,
            primaryAction: presentationAdapter.didRecieveDeposit
        )
        return (controller, presentationAdapter.result)
    }
}

enum TransactionsUIComposer {
    static func compose(
        bitcoinRateUpdater: @escaping () -> AnyPublisher<BitcoinRate, Error>,
        depoist: @escaping () -> AnyPublisher<Transaction, Never>,
        transactionsLoader: @escaping () -> AnyPublisher<[Transaction], Error>
    ) -> TransactionsViewController {
        let presentationAdapter = TransactionsPresentationAdapter(
            depoist: depoist,
            bitcoinRateUpdater: bitcoinRateUpdater,
            transactionsLoader: transactionsLoader
        )
        let controller = TransactionsViewController(
            delegate: presentationAdapter
        )
        presentationAdapter.presenter = TransactionsPresenter(
            view: TransactionsViewAdapter(
                controller: controller
            )
        )
        return controller
    }
}

final class TransactionsPresentationAdapter: TransactionsViewControllerDelegate {
    var presenter: TransactionsPresenter?
    private var cancellables: Set<AnyCancellable> = []
    private let depoist: () -> AnyPublisher<Transaction, Never>
    
    init(
        depoist: @escaping () -> AnyPublisher<Transaction, Never>,
        bitcoinRateUpdater: () -> AnyPublisher<BitcoinRate, Error>,
        transactionsLoader: () -> AnyPublisher<[Transaction], Error>
    ) {
        self.depoist = depoist
        
        bitcoinRateUpdater()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [unowned self] in
                    if case let .failure(error) = $0 {
                        print(error)
                    }
                },
                receiveValue: { [unowned self] in
                    presenter?.didUpdateBitcounRate(with: $0)
                }
            )
            .store(in: &cancellables)
        
        transactionsLoader()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [unowned self] in
                    if case let .failure(error) = $0 {
                        print(error)
                    }
                },
                receiveValue: { [unowned self] in
                    if !$0.isEmpty {
                        presenter?.didLoadTransactions($0)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func didTapAddTransactionButton() {
        
    }
    
    func didTapDepositButton() {
        depoist()
            .sink { [unowned self] in
                presenter?.didRecieveTransaction($0)
            }
            .store(in: &cancellables)
    }
}


import Combine

final class TransactionsViewAdapter: TransactionsView {
    weak var controller: TransactionsViewController?
    private var currentTransactions: [Transaction: TransactionCellController]
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        controller: TransactionsViewController,
        currentTransactions: [Transaction: TransactionCellController] = [:]
    ) {
        self.controller = controller
        self.currentTransactions = currentTransactions

    }
    
    func display(_ viewModel: TransactionsViewModel) {

    }
    
    func display(_ transaction: Transaction) {
        guard let controller else { return }
        let cellController = TransactionCellController(
            viewModel: .init(date: "14:34:55", category: transaction.category.rawValue, amount: transaction.amount)
        )
        currentTransactions[transaction] = cellController
        let section = TransactionsSection(date: .now, items: currentTransactions.map(\.value))
        controller.display([section])
    }
    
    func display(_ transactions: [Transaction]) {
        guard let controller else { return }
        var currentTransactions = currentTransactions
        let transactions: [TransactionCellController] = transactions.map { model in
            if let controller = currentTransactions[model] {
                return controller
            }
            let cellController = TransactionCellController(
                viewModel: .init(date: "14:34:55", category: model.category.rawValue, amount: model.amount)
            )
            currentTransactions[model] = cellController
            return cellController
        }
        self.currentTransactions = currentTransactions
        let section = TransactionsSection(date: .now, items: transactions)
        controller.display([section])
    }
    
    func display(_ formattedBitcoinRate: String) {
        
    }
}
