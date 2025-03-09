//
//  TransactionsStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 09.03.2025.
//

protocol TransactionsStore {
    func insert(_ transaction: Transaction) throws
    func retrieve() throws -> [Transaction]
}
