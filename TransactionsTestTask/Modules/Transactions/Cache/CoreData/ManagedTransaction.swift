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
    @NSManaged var category: String
    @NSManaged var date: Date
}

extension ManagedTransaction {
    static func find(in context: NSManagedObjectContext) throws -> [ManagedTransaction] {
        let request = NSFetchRequest<ManagedTransaction>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request)
    }
}
