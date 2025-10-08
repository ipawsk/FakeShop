//
//  ModelProducts.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    var isFavorite: Bool?
}

enum CodingKeys: String, CodingKey {
    case id, title, price, description, category, image
}
