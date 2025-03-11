//
//  TransactionCellController.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import UIKit

struct TransactionViewModel {
    let transaction: Transaction
    
    var amount: String {
        String(transaction.amount)
    }
    
    var category: String {
        transaction.category.rawValue
    }
    
    var formattedDate: String {
        transaction.date.formatted(date: .omitted, time: .standard)
    }
    
    var amountTextColor: UIColor {
        transaction.category == .deposit ? .green : .black
    }
}

final class TransactionCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let viewModel: TransactionViewModel
    private var cell: TransactionCell?
    
    init(viewModel: TransactionViewModel) {
        self.viewModel = viewModel
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.amountLabel.text = String(viewModel.amount)
        cell?.dateLabel.text = String(viewModel.formattedDate)
        cell?.amountLabel.textColor = viewModel.amountTextColor
        cell?.categoryLabel.text = viewModel.category
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.cell = cell as? TransactionCell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        releaseCellForReuse()
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
