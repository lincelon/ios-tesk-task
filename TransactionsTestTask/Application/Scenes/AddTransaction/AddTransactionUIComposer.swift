//
//  AddTransactionUIComposer.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import Combine

enum AddTransactionUIComposer {
    static func compose() -> (controller: AddTransactionViewController, result: AnyPublisher<Transaction, Never>) {
        let controller = AddTransactionViewController()
        let presentationAdapter = AddTransactionPresentationAdapter()
        controller.didAddTransaction = presentationAdapter.didAddTransaction
        controller.didEnterAmount = presentationAdapter.didEnter(amount:)
        controller.viewDidDissapear = presentationAdapter.viewDidDissappear
        presentationAdapter.presenter = AddTransactionPresenter(
            view: WeakRefVirtualProxy(controller)
        )
        return (controller, presentationAdapter.result)
    }
}
