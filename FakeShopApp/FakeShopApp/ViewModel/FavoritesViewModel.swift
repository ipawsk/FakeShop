//
//  FavoritesViewModel.swift
//  FakeShopApp
//
//  Created by iPaw on 07/10/25.
//

final class FavoritesViewModel {
    var refreshData: () -> Void = {}

    private let repo: ProductRepository
    init(repo: ProductRepository = FakeStoreProductRepository()) {
        self.repo = repo
    }

    private(set) var allProducts: [Product] = [] { didSet { refreshData() } }
    private(set) var errorMessage: String? { didSet { refreshData() } }

    func getFavoritos() {
        Task {
            do {
                let favs = try await repo.getFavorites()     // lee Core Data
                await MainActor.run { self.allProducts = favs }
            } catch {
                await MainActor.run { self.errorMessage = error.localizedDescription }
            }
        }
    }

    func toggle(_ product: Product) {
        Task {
            _ = try? await repo.toggleFavorite(id: product.id) // persiste
            await MainActor.run { self.getFavoritos() }
        }
    }
}
