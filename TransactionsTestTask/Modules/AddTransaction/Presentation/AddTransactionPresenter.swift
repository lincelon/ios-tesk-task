//
//  AddTransactionPresenter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import Foundation

struct AddTransactionViewModel {
    let title: String
    let addTransactionButtonTitle: String
    let amountPlaceholder: String
    let categories: [String]
}

protocol AddTransactionView {
    
    func display(_ viewModel: AddTransactionViewModel)
    func setAddTransactionButtonEnabled(_ isEnabled: Bool)
}

final class AddTransactionPresenter {
    private let view: AddTransactionView
    
    init(view: AddTransactionView) {
        self.view = view
        let viewModel = AddTransactionViewModel(
            title: "Add Transaction",
            addTransactionButtonTitle: "Add",
            amountPlaceholder: "Amount",
            categories: Transaction.Category.allCases.filter { $0 != .deposit }.map(\.rawValue)
        )
        view.display(viewModel)
        view.setAddTransactionButtonEnabled(false)
    }
    
    static func map(amount: String, category: String) -> Transaction {
        Transaction(
            amount: -(Double(amount) ?? .zero),
            date: .now,
            category: .init(rawValue: category) ?? .other
        )
    }
    
    func didEnter(amount: String) {
        if
            let amount = Double(amount),
            amount > 0 {
            view.setAddTransactionButtonEnabled(true)
        } else {
            view.setAddTransactionButtonEnabled(false)
        }
    }
}
