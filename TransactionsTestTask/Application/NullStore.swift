//
//  NullStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

class NullStore {}

extension NullStore: BitcoinRateStore {
    func save(_ localBitcoinRate: BitcoinRate) throws { }
    func retrieve() throws -> BitcoinRate? { .zero }
}

extension NullStore: TransactionsStore {
    func retrieve(offset: Int, limit: Int) throws -> [Transaction] { [] }
    func count() throws -> Int { .zero }
    func insert(_ transaction: Transaction) throws { }
}

extension NullStore: BalanceStore {
    func balance() throws -> Balance? { .zero }
}
