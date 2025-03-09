//
//  ManagedTransaction.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import CoreData

@objc(ManagedTransaction)
class ManagedTransaction: NSManagedObject {
    @NSManaged var amount: Double
    @NSManaged var category: String?
    @NSManaged var date: Date
}
