//
//  ManagedBitcoinRate.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

import CoreData

@objc(ManagedBitcoinRate)
class ManagedBitcoinRate: NSManagedObject {
    @NSManaged var value: Double
}

extension ManagedBitcoinRate {
    static func find(in context: NSManagedObjectContext) throws -> ManagedBitcoinRate? {
        let request = NSFetchRequest<ManagedBitcoinRate>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
}
