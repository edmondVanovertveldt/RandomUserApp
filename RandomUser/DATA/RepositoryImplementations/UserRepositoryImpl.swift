//
//  UserRepositoryImpl.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

protocol UserSettings {
    var nextPage: Int? { get set }
    var seed: String? { get set }
}

@MainActor
final class UserRepositoryImpl: UserRepository {
    private var users: [User] = []
    private var nextPage: Int = 1

    private let apiService: RandomUserAPIService
    private let coreDataRepository: CoreDataUserRepository
    private var userSettings: UserSettings

    init(apiService: RandomUserAPIService,
         coreDataRepository: CoreDataUserRepository,
         userSettings: UserSettings)
    {
        self.apiService = apiService
        self.coreDataRepository = coreDataRepository
        self.userSettings = userSettings
    }

    func reloadUsers() async throws -> [User] {
        await resetUsers()
        return try await fetchNextUsers()
    }

    func fetchNextUsers() async throws -> [User] {
        do {
            let data = try await apiService.fetchUsers(results: 10,
                                                       page: nextPage,
                                                       seed: userSettings.seed)
            let newUsers = data.results.map { User(dto: $0) }
            await updateDatasWithNewPageResults(data: data)
            return newUsers
        } catch let error {
            if error.isConnectivityIssue() && isFirstPage {
                // use cache
                retrieveUsersFromCache()
                return self.users
            } else {
                throw error
            }
        }
    }
}

private extension UserRepositoryImpl {
    func saveUsers(_ users: [User]) async {
        await coreDataRepository.save(users: users)
    }

    func getCachedUsers() -> [User] {
        return coreDataRepository.fetchUsers()
    }

    func resetUsers() async {
        self.users.removeAll()
        await self.coreDataRepository.deleteAllUsers()

        self.nextPage = 1
        self.userSettings.nextPage = 1
        self.userSettings.seed = nil
    }

    func retrieveUsersFromCache() {
        self.users = getCachedUsers()
        self.nextPage = self.userSettings.nextPage ?? 1
    }

    var isFirstPage: Bool {
        nextPage == 1
    }

    func updateDatasWithNewPageResults(data: RandomUserResponse) async {
        let users = data.results.map { User(dto: $0) }
        let seed = data.info.seed

        // Update users
        self.users.append(contentsOf: users)
        await self.saveUsers(self.users)

        // update technical infos (page / seed)
        self.nextPage+=1
        self.userSettings.nextPage = self.nextPage
        self.userSettings.seed = seed
    }
}
