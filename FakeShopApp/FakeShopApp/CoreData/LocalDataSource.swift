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
    
    // Favs
    func toggleFavorite(id: Int) throws -> Bool
    func fetchFavorites() throws -> [Product]
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
                
                //Favoritos en local
                let keepFav = entity.isFavorite
                
                entity.fill(from: p) //Actualiza los datos dede la API (No trae Favs)
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
    
    //MARK: - Functions Favorites
    
    //Cambia el estado de favoritos
    func toggleFavorite(id: Int) throws -> Bool {
        let ctx = stack.viewContext
        var newValue = false
        try ctx.performAndWait { // lo ejecuta dentro de la cola del context
            //Hace un fetch por producto, por id
            let req: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
            req.predicate = NSPredicate(format: "id == %d", id) // lo filtra por el id
            req.fetchLimit = 1 // solo necesito 1
            guard let e = try ctx.fetch(req).first else {
                throw NSError(domain: "NotFound", code: 404) //Lanza el error si no lo encuentra
            }
            e.isFavorite.toggle()
            newValue = e.isFavorite // guarda el valor para regresarlo
            try ctx.save()
        }
        return newValue
    }
    
    func fetchFavorites() throws -> [Product] {
        let ctx = stack.viewContext
        let req: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
        req.predicate = NSPredicate(format: "isFavorite == YES")
        req.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return try ctx.fetch(req).map { $0.toDomain() }
    }
}
