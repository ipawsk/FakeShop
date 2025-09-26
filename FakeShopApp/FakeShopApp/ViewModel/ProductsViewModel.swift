//
//  ProductsViewModel.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import Foundation

final class ProductsViewModel {
    var refreshData: () -> Void = {}
    
    private let repo: ProductRepository
    init(repo: ProductRepository = FakeStoreProductRepository()) {
        self.repo = repo
    }
    
    private(set) var allProducts: [Product] = [] {
        didSet {
            categories = Array(Set(allProducts.map { $0.category.lowercased() })).sorted()
            products = allProducts
        }
    }
    
    private(set) var products: [Product] = []  { didSet { refreshData() } }
    private(set) var categories: [String] = [] { didSet { refreshData() } }
    private(set) var errorMessage: String?     { didSet { refreshData() } }
    
    func cargarProductos() {
        Task {
            do {
                let items = try await repo.getAllOfflineFirst()
                await MainActor.run {
                    self.allProducts = items
                }
            } catch {
                await MainActor.run { self.errorMessage = error.localizedDescription }
            }
        }
    }
    
    func filtrarPorCategoria(_ cat: String?) {
        guard let cat, !cat.isEmpty else {
            products = allProducts
            return
        }
        let lc = cat.lowercased()
        products = allProducts.filter { $0.category.lowercased() == lc }
    }
}
