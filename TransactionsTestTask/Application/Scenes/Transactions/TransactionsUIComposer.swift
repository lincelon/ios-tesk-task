//
//  TransactionsUIComposer.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import Combine

enum TransactionsUIComposer {
    static func compose(
        depoist: @escaping () -> AnyPublisher<Transaction, Never>,
        addTransaction: @escaping () -> AnyPublisher<Transaction, Never>,
        bitcoinRateUpdater: @escaping () -> AnyPublisher<BitcoinRate, Error>,
        transactionsLoader: @escaping (Int) -> AnyPublisher<Paginated<Transaction>, Error>,
        balanceLoader: @escaping () -> AnyPublisher<Balance, Error>
    ) -> TransactionsViewController {
        let presentationAdapter = TransactionsPresentationAdapter(
            depoist: depoist,
            addTransaction: addTransaction,
            bitcoinRateUpdater: bitcoinRateUpdater,
            transactionsLoader: transactionsLoader,
            balanceLoader: balanceLoader
        )
        let controller = TransactionsViewController(
            delegate: presentationAdapter
        )
        controller.set(title: TransactionsPresenter.youBTCBalance, addTransactionButtonTitle: TransactionsPresenter.addTransactionTitle)
        presentationAdapter.presenter = TransactionsPresenter(
            view: TransactionsViewAdapter(
                controller: controller
            )
        )
        return controller
    }
}
