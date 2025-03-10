//
//  TransactionsUIComposer.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import Combine

enum TransactionsUIComposer {
    static func compose(
        bitcoinRateUpdater: @escaping () -> AnyPublisher<BitcoinRate, Error>,
        depoist: @escaping () -> AnyPublisher<Transaction, Never>,
        transactionsLoader: @escaping (Int) -> AnyPublisher<Paginated<Transaction>, Error>
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
