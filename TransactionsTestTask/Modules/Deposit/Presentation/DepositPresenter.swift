//
//  DepositPresenter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 09.03.2025.
//

import Foundation

struct DepositPresenter {
    static let title = "Deposit"
    static let message = "Enter the amount to deposit"
    static let placeholder = "Amount"
    static let cancelButtonTitle = "Cancel"
    static let receiveButtonTitle = "Recieve"
    
    static func map(_ amount: Double) -> Transaction {
        Transaction(
            amount: amount,
            date: .now,
            category: .deposit
        )
    }
}
