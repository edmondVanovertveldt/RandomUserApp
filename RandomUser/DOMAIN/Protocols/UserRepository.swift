//
//  UserRepository.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

protocol UserRepository {
    func reloadUsers() async throws -> [User]
    func fetchNextUsers() async throws -> [User]
}
