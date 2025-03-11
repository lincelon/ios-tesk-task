//
//  LoadMoreCellController.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 10.03.2025.
//

import UIKit

class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let cell = LoadMoreCell()
    private let callback: () -> Void
    private var isExecuted = false
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell.selectionStyle = .none
        cell.titleLabel.text = "Loading"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isExecuted {
            callback()
            isExecuted = true
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}
