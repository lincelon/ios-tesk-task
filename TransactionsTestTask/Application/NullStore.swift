//
//  NullStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

class NullStore {}

extension NullStore: BitcoinRateStore {
    func save(_ localBitcoinRate: LocalBitcoinRate) throws { }
    func retrieve() throws -> LocalBitcoinRate? { .zero }
}

extension NullStore: TransactionsStore {
    func insert(_ transaction: Transaction) throws { }
    func retrieve() throws -> [Transaction] { [] }
}
