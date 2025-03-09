//
//  LocalTransaction.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

class LocalBitcoinRateLoader {
    private let store: BitcoinRateStore
    
    init(store: BitcoinRateStore) {
        self.store = store
    }
}

extension LocalBitcoinRateLoader {
    func load() throws -> BitcoinRate {
        if let bitcoinRate = try store.retrieve() {
            return bitcoinRate
        }
        return .zero
    }
}
