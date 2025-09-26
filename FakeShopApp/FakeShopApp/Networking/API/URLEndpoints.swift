//
//  Endpoints.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import Foundation

enum URLEndpoints {
    static let base = URL(string: "https://fakestoreapi.com")!

    case products
    case product(id: Int)
    case category(String)

    var url: URL {
        switch self {
        case .products:
            return Self.base.appending(path: "products")
        case .product(let id):
            return Self.base.appending(path: "products/\(id)")
        case .category(let name):
            return Self.base.appending(path: "products/categories/\(name)")
        }
    }
}
