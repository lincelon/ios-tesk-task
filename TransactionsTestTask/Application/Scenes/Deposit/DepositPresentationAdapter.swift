//
//  DepositPresentationAdapter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import Combine

final class DepositPresentationAdapter {
    private let resultSubject = PassthroughSubject<Transaction, Never>()

    var result: AnyPublisher<Transaction, Never> {
        resultSubject.first().eraseToAnyPublisher()
    }
    
    func didRecieveDeposit(_ amount: String) {
        guard
            let amount = Double(amount),
            amount > 0
        else { return }
        let transaction = DepositPresenter.map(amount)
        resultSubject.send(transaction)
    }
    
    func didCancel() {
        resultSubject.send(completion: .finished)
    }
}
