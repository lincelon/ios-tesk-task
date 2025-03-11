//
//  TransactionCell.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import UIKit

final class TransactionCell: UITableViewCell {
    let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .gray
        return label
    }()
    
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let amountAndCategoryStackView = UIVerticalStackView(
            arrangedSubviews: [
                amountLabel,
                categoryLabel
            ]
        )
        amountAndCategoryStackView.spacing = 8
        let mainStackView = UIHorizontalStackView(
            arrangedSubviews: [
                amountAndCategoryStackView,
                dateLabel
            ]
        )
        mainStackView.distribution = .equalSpacing
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = .init(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
        addSubview(mainStackView)
        NSLayoutConstraint.activate(
            [
                mainStackView.topAnchor.constraint(equalTo: topAnchor),
                mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        )
    }
}
