//
//  UIStackView+Helpers.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import UIKit

extension UIStackView {
    func withVerticalAlignmnet(_ alignment: UIStackView.Alignment, customization: ((UIStackView) -> Void)? = nil) -> UIStackView {
        let alignmentStackView = UIStackView(arrangedSubviews: [self])
        alignmentStackView.translatesAutoresizingMaskIntoConstraints = false
        alignmentStackView.axis = .horizontal
        alignmentStackView.alignment = alignment
        customization?(self)
        return alignmentStackView
    }
    
    func withHorizonalAlignmnet(_ alignment: UIStackView.Alignment, customization: ((UIStackView) -> Void)? = nil) -> UIStackView {
        let alignmentStackView = UIStackView(arrangedSubviews: [self])
        alignmentStackView.translatesAutoresizingMaskIntoConstraints = false
        alignmentStackView.axis = .vertical
        alignmentStackView.alignment = alignment
        customization?(self)
        return alignmentStackView
    }
}

