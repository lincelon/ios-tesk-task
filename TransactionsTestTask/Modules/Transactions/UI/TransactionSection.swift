//
//  TransactionSection.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 11.03.2025.
//

import Foundation

struct TransactionsSection: Hashable {
    let kind: Kind
    let items: [CellController]
    
    enum Kind: Hashable {
        case regular(date: Date)
        case loadMore
    }
}
