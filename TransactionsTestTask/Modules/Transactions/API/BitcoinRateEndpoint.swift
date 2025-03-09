//
//  BitcoinRateEndpoint.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

enum TransactionsEndpoint {
    case bitcoinRate
    
    func url(baseURL: URL) -> URL {
        switch self {
        case .bitcoinRate:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/v2/assets/bitcoin"
            return components.url!
        }
    }
}
