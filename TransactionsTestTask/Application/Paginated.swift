//
//  Paginated.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

struct Paginated<Item> {
    typealias LoadMoreCompletion = (Result<Self, Error>) -> Void
    
    let items: [Item]
    let loadMore: ((Int, @escaping LoadMoreCompletion) -> Void)?
}

