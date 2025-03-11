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
    
    static func balance(in context: NSManagedObjectContext) throws -> Balance? {
        let keypathExp = NSExpression(forKeyPath: "amount")
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])
        let amountDescription = NSExpressionDescription()
        amountDescription.expression = expression
        amountDescription.name = "amount"
        amountDescription.expressionResultType = .doubleAttributeType
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        request.propertiesToFetch = [amountDescription]
        request.resultType = .dictionaryResultType
        let result = try context.fetch(request)
        let amount = (result.first as? Dictionary<String, Double>)?["amount"]
        return amount
    }
}
