//
//  NiblessView.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import UIKit

open class NiblessView: UIView {
    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(
        *,
        unavailable,
        message: "Loading this view from a nib is unsupported in favor of initializer dependency injection."
    )
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Loading this view from a nib is unsupported in favor of initializer dependency injection.")
    }
}
