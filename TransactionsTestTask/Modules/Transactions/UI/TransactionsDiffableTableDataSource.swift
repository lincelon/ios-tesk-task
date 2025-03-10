//
//  TransactionsDiffableTableDataSource.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import UIKit

final class TransactionsDiffableTableDataSource: UITableViewDiffableDataSource<TransactionsSection, CellController> {
    init(tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, cellController in
            cellController.dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let snapshot = snapshot()
        guard snapshot.sectionIdentifiers.indices.contains(section) else {
            return nil
        }
        switch snapshot.sectionIdentifiers[section].kind {
        case let .regular(date):
            return date.formatted(date: .abbreviated, time: .omitted)
        case .loadMore:
            return nil
        }
    }
}
