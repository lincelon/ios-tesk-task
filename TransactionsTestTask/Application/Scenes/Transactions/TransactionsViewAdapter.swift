//
//  TransactionsViewAdapter.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import Combine
import Foundation

final class TransactionsViewAdapter: TransactionsView {
    weak var controller: TransactionsViewController?
    private var currentSections: [TransactionsSection]
    private var currentLoadMore: ((Int, @escaping Paginated<Transaction>.LoadMoreCompletion) -> Void)?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        controller: TransactionsViewController,
        currentSections: [TransactionsSection] = []
    ) {
        self.controller = controller
        self.currentSections = currentSections
    }
    
    func display(_ transaction: Transaction) {
        let paginated = Paginated(
            items: [transaction],
            loadMore: currentLoadMore
        )
        display(paginated, insertion: .prepend)
    }
    
    func display(_ transactions: Paginated<Transaction>, insertion: Insertion) {
        guard let controller else { return }
        
        let cellControllers = transactions.items.map { transaction in
             let view = TransactionCellController(
                viewModel: .init(transaction: transaction)
            )
            let cellController = CellController(id: transaction, view)
            return cellController
        }
        
        var currentCellControllers: [CellController] = currentSections.flatMap(\.items)
        
        switch insertion {
        case .prepend:
            currentCellControllers.insert(contentsOf: cellControllers, at: 0)
        case .append:
            currentCellControllers.append(contentsOf: cellControllers)
        }
        
        var sections: [TransactionsSection] = group(currentCellControllers)
        currentSections = sections
        
        guard let loadMorePublisher = transactions.loadMorePublisher else {
            controller.display(sections)
            currentLoadMore = nil
            return
        }
        currentLoadMore = transactions.loadMore
        
        let loadMore = LoadMoreCellController(
            callback: { [offset = currentCellControllers.count, weak self] in
                guard let self else { return }
                
                loadMorePublisher(offset)
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: {
                            self.display($0, insertion: .append)
                        }
                    )
                    .store(in: &cancellables)
            }
        )
        
        let loadMoreSection = TransactionsSection(
            kind: .loadMore,
            items: [CellController(id: UUID(), loadMore)]
        )
        sections.append(loadMoreSection)
        controller.display(sections)
    }
        
    func display(_ formattedBitcoinRate: String) {
        
    }
    
    private func group(_ cellControllers : [CellController]) -> [TransactionsSection] {
        let calendar = Calendar.current
        let dateComponents: Set<Calendar.Component> = [.day, .year, .month]
        let grouped = Dictionary(grouping: cellControllers) { cellController -> Date in
            if let transactionDate = (cellController.id as? Transaction)?.date {
                let components = calendar.dateComponents(dateComponents, from: transactionDate)
                return calendar.date(from: components)!
            }
            return Date()
        }
        return grouped
            .map { .init(kind: .regular(date: $0), items: $1) }
            .sorted { left, right in
                if
                    case let .regular(leftDate) = left.kind,
                    case let .regular(rightDate) = right.kind {
                    return leftDate > rightDate
                } else {
                    return false
                }
            }
    }
}
