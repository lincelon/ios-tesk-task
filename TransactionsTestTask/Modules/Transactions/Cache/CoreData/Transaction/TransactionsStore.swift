//
//  TransactionsStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 09.03.2025.
//

protocol TransactionsStore {
    func insert(_ transaction: Transaction) throws
    func retrieve(offset: Int, limit: Int) throws -> [Transaction]
    func count() throws -> Int
}
