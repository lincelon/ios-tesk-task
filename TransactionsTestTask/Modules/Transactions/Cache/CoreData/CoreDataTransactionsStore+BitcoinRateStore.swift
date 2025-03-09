//
//  CoreDataTransactionsStore+BitcoinRateStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

extension CoreDataTransactionsStore: BitcoinRateStore {
    func save(_ localBitcoinRate: LocalBitcoinRate) throws {
        try performSync { context in
            Result {
                let managedBitcoinRate = try ManagedBitcoinRate.newUniqueInstance(in: context) as ManagedBitcoinRate
                managedBitcoinRate.value = localBitcoinRate
                try context.save()
            }
        }
    }
    
    func retrieve() throws -> LocalBitcoinRate? {
        try performSync { context in
            Result {
                try ManagedBitcoinRate.find(in: context)?.value
            }
        }
    }
}
