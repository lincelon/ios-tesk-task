//
//  TransactionsPresenter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

enum Insertion {
    case prepend
    case append
}


protocol TransactionsView {
    func display(_ transactions: Paginated<Transaction>, insertion: Insertion)
    func display(_ transaction: Transaction)
    func display(formattedBitcoinRate: String)
    func display(balance: String)
}

final class TransactionsPresenter {
    private let view: TransactionsView
    static let addTransactionTitle: String = "Add transaction"
    static let youBTCBalance: String = "You BTC balance"
    
    init(view: TransactionsView) {
        self.view = view
    }
    
    func didUpdateBitcounRate(with rate: Double) {
        let formattedBitcoinRate = "1 BTC – $\(String(format: "%.2f", rate))"
        view.display(formattedBitcoinRate: formattedBitcoinRate)
    }
    
    func didLoadTransactions(_ transactions: Paginated<Transaction>) {
        view.display(transactions, insertion: .append)
    }
    
    func didRecieveTransaction(_ transaction: Transaction) {
        view.display(transaction)
    }
    
    func didUpdate(balance: Balance) {
        let balance = balance.formatted(.number.precision(.fractionLength(0...2)))
        view.display(balance: balance)
    }
}
