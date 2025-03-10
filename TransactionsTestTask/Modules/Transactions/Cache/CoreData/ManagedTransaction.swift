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
    static func find(
        in context: NSManagedObjectContext,
        offset: Int,
        limit: Int
    ) throws -> [ManagedTransaction] {
        let sortDescriptor = NSSortDescriptor(
            key: #keyPath(ManagedTransaction.date),
            ascending: false
        )
        let request = NSFetchRequest<ManagedTransaction>(entityName: entity().name!)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = limit
        request.fetchOffset = offset
        return try context.fetch(request)
    }
    
    static func count(in context: NSManagedObjectContext) throws -> Int {
        let request = NSFetchRequest<ManagedTransaction>(entityName: entity().name!)
        let count = try context.count(for: request)
        return count
    }
}
