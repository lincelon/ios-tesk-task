//
//  TransactionsPresentationAdapter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import Combine
import Foundation

final class TransactionsPresentationAdapter: TransactionsViewControllerDelegate {
    var presenter: TransactionsPresenter?
    private var cancellables: Set<AnyCancellable> = []
    private let depoist: () -> AnyPublisher<Transaction, Never>
    private let addTransaction: () -> AnyPublisher<Transaction, Never>
    private let balanceLoader: () -> AnyPublisher<Balance, Error>
    
    init(
        depoist: @escaping () -> AnyPublisher<Transaction, Never>,
        addTransaction: @escaping () -> AnyPublisher<Transaction, Never>,
        bitcoinRateUpdater: () -> AnyPublisher<BitcoinRate, Error>,
        transactionsLoader: (Int) -> AnyPublisher<Paginated<Transaction>, Error>,
        balanceLoader: @escaping () -> AnyPublisher<Balance, Error>
    ) {
        self.depoist = depoist
        self.addTransaction = addTransaction
        self.balanceLoader = balanceLoader
        
        bitcoinRateUpdater()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [unowned self] in
                    presenter?.didUpdateBitcounRate(with: $0)
                }
            )
            .store(in: &cancellables)
        
        transactionsLoader(.zero)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [unowned self] in
                    if !$0.items.isEmpty {
                        presenter?.didLoadTransactions($0)
                    }
                }
            )
            .store(in: &cancellables)
        
        balanceLoader()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [unowned self] in
                    presenter?.didUpdate(balance: $0)
                }
            )
            .store(in: &cancellables)
    }
    
    func didTapAddTransactionButton() {
        addTransaction()
            .handleEvents(
                receiveOutput: { [unowned self] in
                    presenter?.didRecieveTransaction($0)
                }
            )
            .flatMap { [unowned self] _ in
                balanceLoader()
            }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [unowned self] in
                    presenter?.didUpdate(balance: $0)
                }
            )
            .store(in: &cancellables)
    }
    
    func didTapDepositButton() {
        depoist()
            .handleEvents(
                receiveOutput: { [unowned self] in
                    presenter?.didRecieveTransaction($0)
                }
            )
            .flatMap { [unowned self] _ in
                balanceLoader()
            }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [unowned self] in
                    presenter?.didUpdate(balance: $0)
                }
            )
            .store(in: &cancellables)
    }
}
