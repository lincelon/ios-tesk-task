//
//  CoreDataTransactionsStore+BalanceStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 11.03.2025.
//

import Foundation

extension CoreDataTransactionsStore: BalanceStore {
    func balance() throws -> Balance? {
        try performSync { context in
            Result {
                try ManagedTransaction.balance(in: context)
            }
        }
    }
}
