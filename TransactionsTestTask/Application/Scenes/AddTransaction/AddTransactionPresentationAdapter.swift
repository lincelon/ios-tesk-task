//
//  AddTransactionPresentationAdapter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 11.03.2025.
//

import Combine

final class AddTransactionPresentationAdapter {
    private let resultSubject = PassthroughSubject<Transaction, Never>()
    var presenter: AddTransactionPresenter?
    
    var result: AnyPublisher<Transaction, Never> {
        resultSubject.first().eraseToAnyPublisher()
    }
    
    func didAddTransaction(amount: String, category: String) {
        let transaction = AddTransactionPresenter.map(amount: amount, category: category)
        resultSubject.send(transaction)
    }
    
    func didEnter(amount: String) {
        presenter?.didEnter(amount: amount)
    }
    
    func viewDidDissappear() {
        resultSubject.send(completion: .finished)
    }
}
