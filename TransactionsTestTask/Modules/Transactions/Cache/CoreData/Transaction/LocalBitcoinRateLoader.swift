//
//  LocalTransaction.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import Foundation

class LocalTransactionsLoader {
    private let limit: Int = 20
    private let store: TransactionsStore
    
    init(store: TransactionsStore) {
        self.store = store
    }
}

extension LocalTransactionsLoader {
    func load(offset: Int = .zero) throws -> (items: [Transaction], nextPage: Bool) {
        let totalItemCount = try store.count()
        let items = try store.retrieve(offset: offset, limit: limit)
        let nextPage = items.count + offset < totalItemCount
        return (items, nextPage)
    }
}
