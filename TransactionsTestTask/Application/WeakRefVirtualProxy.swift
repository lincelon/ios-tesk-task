//
//  WeakRefVirtualProxy.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: TransactionsView where T: TransactionsView {
    func display(_ transactions: Paginated<Transaction>, insertion: Insertion) {
        object?.display(transactions, insertion: insertion)
    }
    
    func display(_ transaction: Transaction) {
        object?.display(transaction)
    }
        
    func display(_ formattedBitcoinRate: String) {
        object?.display(formattedBitcoinRate)
    }
}

extension WeakRefVirtualProxy: TransactionsViewControllerDelegate where T: TransactionsViewControllerDelegate {
    func didTapDepositButton() {
        object?.didTapDepositButton()
    }
    
    func didTapAddTransactionButton() {
        object?.didTapAddTransactionButton()
    }
}

extension WeakRefVirtualProxy: AddTransactionView where T: AddTransactionView {
    func display(_ viewModel: AddTransactionViewModel) {
        object?.display(viewModel)
    }
    
    func setAddTransactionButtonEnabled(_ isEnabled: Bool) {
        object?.setAddTransactionButtonEnabled(isEnabled)
    }
}
