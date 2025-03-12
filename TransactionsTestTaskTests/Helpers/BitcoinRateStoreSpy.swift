//
//  BitcoinRateStoreSpy.swift
//  TransactionsTestTaskTests
//
//  Created by Maksym Soroka on 12.03.2025.
//

@testable import TransactionsTestTask

final class BitcoinRateStoreSpy: BitcoinRateStore {
    var storedRate: BitcoinRate?
    var saveTimes = 0
    
    func save(_ bitcoinRate: BitcoinRate) throws {
        storedRate = bitcoinRate
        saveTimes += 1
    }
    
    func retrieve() throws -> BitcoinRate? {
        storedRate
    }
}
