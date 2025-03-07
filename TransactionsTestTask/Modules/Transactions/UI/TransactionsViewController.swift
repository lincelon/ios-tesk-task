//
//  ViewController.swift
//  TransactionsTestTask
//
//

import UIKit

protocol TransactionsViewControllerDelegate {
    func didTapAddTransactionButton()
    func didTapDepositButton()
}

struct TransactionsSection: Hashable {
    let date: Date
    let items: [TransactionCellController]
}

final class TransactionsViewController: NiblessViewController {
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.rowHeight = UITableView.automaticDimension
        view.register(TransactionCell.self)
        view.alwaysBounceVertical = false
        view.allowsSelection = false
        return view
    }()
       
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .black
        label.text = "8000000 BTC"
        return label
    }()
    
    private let depositButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.buttonSize = .medium
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private lazy var dataSource = TransactionsDiffableTableDataSource(tableView: tableView)
    var delegate: TransactionsViewControllerDelegate?
    
    convenience init(delegate: TransactionsViewControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        display([.init(date: Date(), items: [.init(viewModel: .init(date: "1", category: "1", amount: 1))])])
    }
    
    private func setupViews() {
        view.backgroundColor = .red
        let balanceAndDepositStackView = UIHorizontalStackView(
            arrangedSubviews: [
                balanceLabel,
                depositButton
            ]
        ).withHorizonalAlignmnet(.leading)
        let descriptionStackView = UIVerticalStackView(
            arrangedSubviews: [
                balanceAndDepositStackView
            ]
        )
        let mainStackView = UIVerticalStackView(
            arrangedSubviews: [
                descriptionStackView,
                tableView
            ]
        )
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate(
            [
                mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ]
        )
    }
    
    private func cellController(at indexPath: IndexPath) -> TransactionCellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    func display(_ sections: [TransactionsSection]) {
        var snapshot = NSDiffableDataSourceSnapshot<TransactionsSection, TransactionCellController>()
        sections.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension TransactionsViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        
    }
}

extension TransactionsViewController: TransactionsView {
    func display(_ viewModel: TransactionsViewModel) {
        
    }
}

#Preview {
    TransactionsViewController()
}

