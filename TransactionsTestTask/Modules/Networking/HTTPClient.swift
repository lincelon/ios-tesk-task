//
//  HTTPClient.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

protocol HTTPClient {
    typealias Result = Swift.Result<(data: Data, response: HTTPURLResponse), Error>
    
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
