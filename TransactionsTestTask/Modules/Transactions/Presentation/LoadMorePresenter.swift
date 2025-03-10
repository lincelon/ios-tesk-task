//
//  LoadMorePresenter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//


protocol LoadMoreView {
    func display(_ transactions: Paginated<Transaction>, insertion: Insertion)
}

final class LoadMorePresenter {
    private let view: LoadMoreView
    static let title = "Loading"

    init(view: LoadMoreView) {
        self.view = view
    }
    
    func didLoadTransaction(_ transactions: Paginated<Transaction>) {
        view.display(transactions, insertion: .append)
    }
}
