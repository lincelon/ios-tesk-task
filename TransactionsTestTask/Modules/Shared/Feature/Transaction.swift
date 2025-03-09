//
//  Transaction.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 09.03.2025.
//

import Foundation

struct Transaction {
    let amount: Double
    let date: Date
    let category: Category
    
    enum Category: String {
        case groceries
        case taxi
        case electronics
        case restaurant
        case other
        case deposit
    }
}

extension Transaction: Hashable { }
