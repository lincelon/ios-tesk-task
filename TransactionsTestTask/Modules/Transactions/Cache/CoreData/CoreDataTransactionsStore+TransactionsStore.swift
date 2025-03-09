//
//  CoreDataTransactionsStore+TransactionsStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 09.03.2025.
//

import Foundation

extension CoreDataTransactionsStore: TransactionsStore {
    func insert(_ transaction: Transaction) throws {
        try performSync { context in
            Result {
                let managedTransaction = try ManagedTransaction.newUniqueInstance(in: context) as ManagedTransaction
                managedTransaction.amount = transaction.amount
                managedTransaction.date = transaction.date
                managedTransaction.category = transaction.category.rawValue
                try context.save()
            }
        }
    }
    
    func retrieve() throws -> [Transaction] {
        try performSync { context in
            Result {
                try ManagedTransaction.find(in: context).compactMap {
                    guard let category = Transaction.Category(rawValue: $0.category) else {
                        return nil
                    }
                    return Transaction(
                        amount: $0.amount,
                        date: $0.date,
                        category: category
                    )
                }
            }
        }
    }
}
