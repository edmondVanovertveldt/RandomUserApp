//
//  UserListViewModel.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import Foundation

@MainActor
final class UserListViewModel {
    @Published private(set) var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published private(set) var isFirstLoadDone: Bool = false
    @Published var isLoadingMoreUsers: Bool = false

    private let fetchUsersUseCase: FetchUsersUseCase
    private let reloadUsersUseCase: ReloadUsersUseCase

    init(fetchUsersUseCase: FetchUsersUseCase,
         reloadUsersUseCase: ReloadUsersUseCase)
    {
        self.fetchUsersUseCase = fetchUsersUseCase
        self.reloadUsersUseCase = reloadUsersUseCase
    }

    func loadInitialUsers() async {
        isLoading = true
        await fetchUsers()
        isLoading = false
        isFirstLoadDone = true
    }

    func refresh() async {
        do {
            self.users = try await reloadUsersUseCase.execute()
        } catch let error {
            errorMessage = error.localizedDescription
        }
    }

    func loadMoreUsersIfNeeded(currentIndex: Int) async {
        guard !isLoading && !isLoadingMoreUsers else { return }
        guard currentIndex >= users.count - 4 else { return }

        isLoadingMoreUsers = true
        await fetchUsers()
        isLoadingMoreUsers = false
    }

    private func fetchUsers() async {
        do {
            let newUsers = try await fetchUsersUseCase.execute()
            users.append(contentsOf: newUsers)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: -
    // MARK: Properties

    func user(at index: Int) -> User {
        return users[index]
    }

    var numberOfUsers: Int {
        return users.count
    }
}
