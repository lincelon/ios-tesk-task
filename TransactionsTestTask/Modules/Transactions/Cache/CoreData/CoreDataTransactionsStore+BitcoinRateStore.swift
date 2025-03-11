//
//  CoreDataTransactionsStore+BitcoinRateStore.swift
//  TransactionsTestTask
//
//  Created by Maksym Soroka on 07.03.2025.
//

extension CoreDataTransactionsStore: BitcoinRateStore {
    func save(_ bitcoinRate: BitcoinRate) throws {
        try performSync { context in
            Result {
                try ManagedBitcoinRate.find(in: context).map(context.delete).map(context.save)
                let managedBitcoinRate = try ManagedBitcoinRate.newUniqueInstance(in: context) as ManagedBitcoinRate
                managedBitcoinRate.value = bitcoinRate                
                try context.save()
            }
        }
    }
    
    func retrieve() throws -> BitcoinRate? {
        try performSync { context in
            Result {
                try ManagedBitcoinRate.find(in: context)?.value
            }
        }
    }
}
