//
//  BalanceStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 11.03.2025.
//

import UIKit

protocol BalanceStore {
    func balance() throws -> Balance?
}
