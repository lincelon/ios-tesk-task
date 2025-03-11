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

final class TransactionsViewController: NiblessViewController {
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.rowHeight = UITableView.automaticDimension
        view.register(TransactionCell.self)
        view.register(LoadMoreCell.self)
        view.alwaysBounceVertical = false
        view.allowsSelection = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let bitcoinRateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let yourBTCBalanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        return label
    }()
    
    private let balanceAmountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let depositButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "plus.circle.fill")
        let button = UIButton(configuration: configuration)
        return button
    }()
    
    private let addTransactionButton: UIButton = {
        let button = UIButton(type: .system)
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
        depositButton.addTarget(self, action: #selector(didTapDepositButton), for: .touchUpInside)
        addTransactionButton.addTarget(self, action: #selector(didTapAddTransactionButton), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        tableView.delegate = self
        let bitcoinRateStackView = UIHorizontalStackView(
            arrangedSubviews: [bitcoinRateLabel]
        ).withHorizonalAlignmnet(.trailing)
        let balanceAndDepositStackView = UIHorizontalStackView(
            arrangedSubviews: [
                balanceAmountLabel,
                depositButton
            ]
        ).withHorizonalAlignmnet(.center)
        let descriptionStackView = UIVerticalStackView(
            arrangedSubviews: [
                bitcoinRateStackView,
                yourBTCBalanceLabel,
                balanceAndDepositStackView,
                addTransactionButton
            ]
        )
        descriptionStackView.spacing = 16
        descriptionStackView.isLayoutMarginsRelativeArrangement = true
        descriptionStackView.layoutMargins = .init(
            top: 0,
            left: 16,
            bottom: 16,
            right: 16
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
                mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }
    
    private func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    func display(_ sections: [TransactionsSection]) {
        var snapshot = NSDiffableDataSourceSnapshot<TransactionsSection, CellController>()
        sections.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func display(formattedBitcoinRate: String) {
        bitcoinRateLabel.text = formattedBitcoinRate
    }
    
    func display(balance: String) {
        balanceAmountLabel.text = balance
    }
    
    func set(title: String, addTransactionButtonTitle: String) {
        yourBTCBalanceLabel.text = title
        addTransactionButton.setTitle(addTransactionButtonTitle, for: .normal)
    }
}

extension TransactionsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cellController(at: indexPath)?.delegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
}

private extension TransactionsViewController {
    @objc
    func didTapDepositButton() {
        delegate?.didTapDepositButton()
    }
    
    @objc
    func didTapAddTransactionButton() {
        delegate?.didTapAddTransactionButton()
    }
}
