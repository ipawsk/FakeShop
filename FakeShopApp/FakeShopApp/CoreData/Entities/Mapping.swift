//
//  Mapping.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//
import CoreData

extension ProductEntity {
    func toDomain() -> Product { //convierte la entidad de CoreData  y devuelve Product
        Product(
            id: Int(id),
            title: title ?? "",
            price: price,
            description: productDescription ?? "",
            category: category ?? "",
            image: image ?? ""
        )
    }

    func fill(from p: Product) { //guarda/actualiza ProductEntity con datos de Product`
        id = Int64(p.id)
        title = p.title
        price = p.price
        productDescription = p.description
        category = p.category
        image = p.image
    }
}
