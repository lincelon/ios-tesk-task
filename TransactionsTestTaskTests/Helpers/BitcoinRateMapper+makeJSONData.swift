//
//  BitcoinRateMapper+makeJSONData.swift
//  TransactionsTestTaskTests
//
//  Created by Maksym Soroka on 12.03.2025.
//

import Foundation
@testable import TransactionsTestTask

extension BitcoinRateMapper {
    static func makeJSONData(for bitcoinRate: Double) -> Data {
        let data = try! JSONSerialization.data(
            withJSONObject: [
                "data": [
                    "priceUsd": String(bitcoinRate)
                ]
            ]
        )
        return data
    }
}
