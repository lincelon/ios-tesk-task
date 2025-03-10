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
    
    init(
        depoist: @escaping () -> AnyPublisher<Transaction, Never>,
        bitcoinRateUpdater: () -> AnyPublisher<BitcoinRate, Error>,
        transactionsLoader: (Int) -> AnyPublisher<Paginated<Transaction>, Error>
    ) {
        self.depoist = depoist
        
        bitcoinRateUpdater()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [unowned self] in
                    if case let .failure(error) = $0 {
                        print(error)
                    }
                },
                receiveValue: { [unowned self] in
                    presenter?.didUpdateBitcounRate(with: $0)
                }
            )
            .store(in: &cancellables)
        
        transactionsLoader(.zero)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [unowned self] in
                    if case let .failure(error) = $0 {
                        print(error)
                    }
                },
                receiveValue: { [unowned self] in
                    if !$0.items.isEmpty {
                        presenter?.didLoadTransactions($0)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func didTapAddTransactionButton() {
        
    }
    
    func didTapDepositButton() {
        depoist()
            .sink { [unowned self] in
                presenter?.didRecieveTransaction($0)
            }
            .store(in: &cancellables)
    }
}
