//
//  RandomUserAPIService.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import Foundation

final class RandomUserAPIService {

    func fetchUsers(results: Int, page: Int, seed: String? = nil) async throws -> RandomUserResponse {
        // Build the request
        var components = URLComponents(string: "https://randomuser.me/api/")
        var queryItems = [
            URLQueryItem(name: "results", value: "\(results)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]

        if let seed = seed {
            queryItems.append(URLQueryItem(name: "seed", value: seed))
        }

        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        // Call WS
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(RandomUserResponse.self, from: data)
        return decoded
    }
}
