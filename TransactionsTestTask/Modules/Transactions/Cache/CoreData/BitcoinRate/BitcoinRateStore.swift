//
//  BitcoinRateStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

protocol BitcoinRateStore {
    func save(_ bitcoinRate: BitcoinRate) throws
    func retrieve() throws -> BitcoinRate?
}
