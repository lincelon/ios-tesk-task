//
//  TransactionCell.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import UIKit

final class TransactionCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
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
        let stackView = UIHorizontalStackView(
            arrangedSubviews: [
                titleLabel
            ]
        )
        addSubview(stackView)
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        )
    }
}
