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
    func display(_ viewModel: TransactionsViewModel) {
        object?.display(viewModel)
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
