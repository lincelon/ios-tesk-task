//
//  UIAlertController+UITextField.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import UIKit

extension UIAlertController {
    static func withTextField(
        title: String,
        message: String,
        placeholder: String,
        cancelTitle: String,
        cancelAction: @escaping () -> (),
        primaryTitle: String,
        primaryAction: @escaping (String) -> ()
    ) -> UIAlertController {
        let controller = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        controller.addTextField { textField in
            textField.placeholder = placeholder
            textField.keyboardType = .decimalPad
        }
        let primaryAction = UIAlertAction(
            title: primaryTitle,
            style: .default
        ) { [unowned controller] _ in
            if
                let textField = controller.textFields?.first,
                let value = textField.text {
                primaryAction(value)
            }
        }
        
        let cancelAction = UIAlertAction(
            title: cancelTitle,
            style: .cancel
        ) { _ in
            cancelAction()
        }
        controller.addAction(primaryAction)
        controller.addAction(cancelAction)
        return controller
    }
}
