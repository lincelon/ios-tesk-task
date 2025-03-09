//
//  TransactionsPresenter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

struct TransactionsViewModel {
    let balance: Double
}

protocol TransactionsView {
    func display(_ viewModel: TransactionsViewModel)
    func display(_ transactions: [Transaction])
    func display(_ transaction: Transaction)
    func display(_ formattedBitcoinRate: String)
}

final class TransactionsPresenter {
    private let view: TransactionsView

    init(
        view: TransactionsView
    ) {
        self.view = view
    }
    
    func didUpdateBitcounRate(with rate: Double) {
        let formattedRate = "1 BTC – $\(String(format: "%.2f", rate))"
        view.display(formattedRate)
    }
    
    func didLoadTransactions(_ transactions: [Transaction]) {
        view.display(transactions)
    }
    
    func didRecieveTransaction(_ transaction: Transaction) {
        view.display(transaction)
    }
}
