//
//  SceneDelegate.swift
//  TransactionsTestTask
//
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = TransactionsUIComposer.compose(
            bitcoinRateUpdater: {
                
            }
        )
        window?.makeKeyAndVisible()
    }
}

enum TransactionsUIComposer {
    static func compose(
        bitcoinRateUpdater: @escaping () -> AnyPublisher<Double, Error>
    ) -> TransactionsViewController {
        let transactionPresentationAdapter = TransactionsPresentationAdapter(
            bitcoinRateUpdater: bitcoinRateUpdater
        )
        let controller = TransactionsViewController(
            delegate: WeakRefVirtualProxy(transactionPresentationAdapter)
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
    private var cancellable: AnyCancellable?
    
    init(
        bitcoinRateUpdater: () -> AnyPublisher<Double, Error>
    ) {
        cancellable = bitcoinRateUpdater()
            .sink(
                receiveCompletion: { [unowned self] in
                    if case let .failure(_) = $0 {
                        
                    }
                },
                receiveValue: { [unowned self] in
                    presenter?.didUpdateBitcounRate(rate: $0)
                }
            )
            
    }
    
    func didTapAddTransactionButton() {
        
    }
    
    func didTapDepositButton() {
        
    }
}
