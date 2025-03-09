//
//  BitcoinRateStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

protocol BitcoinRateStore {
    func save(_ localBitcoinRate: LocalBitcoinRate) throws
    func retrieve() throws -> LocalBitcoinRate?
}
