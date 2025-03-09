//
//  TransactionsPresenter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

struct TransactionsViewModel {
    let balance: Double
}

struct TransactionViewModel {
    let date: String
    let category: String
    let amount: Double
}

protocol TransactionsView {
    func display(_ viewModel: TransactionsViewModel)
    func display(_ formattedBitcoinRate: String)
}

final class TransactionsPresenter {
    private let view: TransactionsView

    init(
        view: TransactionsView
    ) {
        self.view = view
    }
    
    func didUpdateBitcounRate(rate: Double) {
        let formattedRate = "1 BTC – $\(String(format: "%.2f", rate))"
        view.display(formattedRate)
    }
}
