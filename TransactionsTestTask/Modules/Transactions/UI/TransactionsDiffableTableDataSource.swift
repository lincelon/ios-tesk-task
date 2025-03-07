//
//  TransactionsDiffableTableDataSource.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import UIKit

final class TransactionsDiffableTableDataSource: UITableViewDiffableDataSource<TransactionsSection, TransactionCellController> {
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, cellController in
            cellController.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let snapshot = snapshot()
        guard snapshot.sectionIdentifiers.indices.contains(section) else {
            return nil
        }
        let date = snapshot.sectionIdentifiers[section].date
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
