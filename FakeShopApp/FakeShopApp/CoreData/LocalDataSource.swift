//
//  LocalDataSource.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import CoreData
import Foundation

protocol LocalDataSource {
    func saveProducts(_ products: [Product]) throws
    func loadProducts() throws -> [Product]
    func loadProducts(category: String) throws -> [Product]
    func clear() throws
    func saveCacheDate(_ date: Date) throws
    func loadCacheDate() throws -> Date?
}

struct CoreDataLocalDataSource: LocalDataSource {
    private let stack: CoreDataStack
    private let cacheKey = "productsCacheDate"

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    func saveProducts(_ products: [Product]) throws {
        let ctx = stack.newBackgroundContext()
        try ctx.performAndWait {
            let fetch = NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
            let ids = products.map { Int64($0.id) }

            fetch.predicate = NSPredicate(format: "id IN %@", ids)
            let existing = try ctx.fetch(fetch)
            var map: [Int64: ProductEntity] = [:]
            for e in existing { map[e.id] = e }

            for p in products {
                let key = Int64(p.id)
                let entity = map[key] ?? ProductEntity(context: ctx)
                entity.fill(from: p)
                map[key] = entity
            }
            if ctx.hasChanges { try ctx.save() }
        }
    }

    func loadProducts() throws -> [Product] {
        let ctx = stack.viewContext
        let req = NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let items = try ctx.fetch(req)
        return items.map { $0.toDomain() }
    }

    func loadProducts(category: String) throws -> [Product] {
        let ctx = stack.viewContext
        let req = NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
        req.predicate = NSPredicate(format: "category ==[c] %@", category)
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let items = try ctx.fetch(req)
        return items.map { $0.toDomain() }
    }

    func clear() throws {
        let ctx = stack.newBackgroundContext()
        try ctx.performAndWait {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductEntity")
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            try ctx.execute(delete)
            if ctx.hasChanges { try ctx.save() }
        }
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }

    func saveCacheDate(_ date: Date) throws {
        UserDefaults.standard.set(date, forKey: cacheKey)
    }

    func loadCacheDate() throws -> Date? {
        UserDefaults.standard.object(forKey: cacheKey) as? Date
    }
}
