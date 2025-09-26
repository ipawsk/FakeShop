//
//  CoreDataStack.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack() //singleton
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "Products") // nombre del .xcdatamodeld
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores { _, error in // abre (si existe) o crea el archivo donde se guardan los datos
            if let error = error { fatalError("Core Data error: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var viewContext: NSManagedObjectContext { container.viewContext }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let backContext = container.newBackgroundContext()
        backContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return backContext
    }
}
