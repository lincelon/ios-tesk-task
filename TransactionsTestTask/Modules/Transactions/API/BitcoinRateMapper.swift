//
//  BitcoinRateMapper.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

enum BitcoinRateMapper {
    private struct Root: Decodable {
        private let data: Data
        
        private struct Data: Decodable {
            let priceUsd: String
        }
        
        var bitcoinRate: BitcoinRate {
            Double(data.priceUsd) ?? .zero
        }
    }
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> BitcoinRate {
        guard isOK(response), let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        print(root.bitcoinRate)
        return root.bitcoinRate
    }
}

private extension BitcoinRateMapper {
    static var OK_200: Int { 200 }

    static func isOK(_ response: HTTPURLResponse) -> Bool {
        response.statusCode == OK_200
    }
}
