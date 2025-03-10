//
//  TransactionsViewAdapter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

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
