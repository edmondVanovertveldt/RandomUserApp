//
//  ReloadUsersUseCase.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

final class ReloadUsersUseCase {
    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute() async throws -> [User] {
        try await repository.reloadUsers()
    }
}
