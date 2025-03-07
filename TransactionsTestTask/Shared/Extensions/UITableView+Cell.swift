//
//  UITableView+Cell.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import UIKit

public extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
    
    
    func register<T: UITableViewCell>(_ name: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: name))
    }
}
