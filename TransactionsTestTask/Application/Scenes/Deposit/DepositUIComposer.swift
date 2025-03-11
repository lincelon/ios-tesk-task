//
//  DepositUIComposer.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import UIKit
import Combine

enum DepositUIComposer {
    static func compose() -> (controller: UIAlertController, result: AnyPublisher<Transaction, Never>) {
        let presentationAdapter = DepositPresentationAdapter()
        let controller = UIAlertController.withTextField(
            title: DepositPresenter.title,
            message: DepositPresenter.message,
            placeholder: DepositPresenter.placeholder,
            cancelTitle: DepositPresenter.cancelButtonTitle,
            cancelAction: presentationAdapter.didCancel,
            primaryTitle: DepositPresenter.receiveButtonTitle,
            primaryAction: presentationAdapter.didRecieveDeposit
        )
        return (controller, presentationAdapter.result)
    }
}
