//
//  RemoteDataSource.swift
//  FakeShopApp
//
//  Created by iPaw on 24/09/25.
//

import Foundation

protocol RemoteDataSource {
    func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T
}

struct URLSessionClient: RemoteDataSource {
    func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
