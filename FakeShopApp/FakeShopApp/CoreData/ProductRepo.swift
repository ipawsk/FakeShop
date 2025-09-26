//
//  ProductRepo.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import Foundation
import Network

protocol ProductRepository {
    func getAllOfflineFirst() async throws -> [Product]
    func getByCategoryOfflineFirst(_ category: String) async throws -> [Product]
    func refreshAll() async throws -> [Product]
    func refreshCategory(_ category: String) async throws -> [Product]
    func isCacheStale(maxAge: TimeInterval) -> Bool
}

class FakeStoreProductRepository: ProductRepository {
    private let remote: RemoteDataSource
    private let local: LocalDataSource
    private let monitor = NWPathMonitor()
    private var online = true

    init(remote: RemoteDataSource = URLSessionClient(),
         local: LocalDataSource = CoreDataLocalDataSource()) {
        self.remote = remote
        self.local = local
        let q = DispatchQueue(label: "net.monitor")
        monitor.pathUpdateHandler = { [weak self] path in self?.online = (path.status == .satisfied) }
        monitor.start(queue: q)
    }

    func isCacheStale(maxAge: TimeInterval) -> Bool {
        let saved = (try? local.loadCacheDate()) ?? .distantPast
        return Date().timeIntervalSince(saved) > maxAge
    }

    func getAllOfflineFirst() async throws -> [Product] {
        // primero Core Data
        let cached = (try? local.loadProducts()) ?? []
        if !cached.isEmpty {
            // revalidar en segundo plano si es necesario
            if online, isCacheStale(maxAge: 60*10) {
                Task { _ = try? await refreshAll() }
            }
            return cached
        }
        //  no hay caché -> remoto
        return try await refreshAll()
    }

    func getByCategoryOfflineFirst(_ category: String) async throws -> [Product] {
        let cached = (try? local.loadProducts(category: category)) ?? []
        if !cached.isEmpty {
            if online, isCacheStale(maxAge: 60*10) {
                Task { _ = try? await refreshCategory(category) }
            }
            return cached
        }
        return try await refreshCategory(category)
    }

    func refreshAll() async throws -> [Product] {
        let fresh = try await remote.get([Product].self, from: URLEndpoints.products.url)
        try local.saveProducts(fresh)
        try local.saveCacheDate(Date())
        return fresh
    }

    func refreshCategory(_ category: String) async throws -> [Product] {
        let fresh = try await remote.get([Product].self, from: URLEndpoints.category(category).url)
        try local.saveProducts(fresh) // guardamos/actualizamos solo los de esa categoría
        try local.saveCacheDate(Date())
        return fresh
    }
}
