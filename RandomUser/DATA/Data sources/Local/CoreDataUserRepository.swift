//
//  CoreDataUserRepository.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import Foundation
import CoreData

final class CoreDataUserRepository {
    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext

    init(coreDataStack: CoreDataStack) {
        self.viewContext = coreDataStack.viewContext
        self.backgroundContext = coreDataStack.backgroundContext
    }

    func save(users: [User]) async {
        await backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            self.deleteAllUsersSync()

            users.forEach { user in
                let entity = UserEntity(context: self.backgroundContext)
                entity.id = user.id
                entity.fullName = user.fullName
                entity.email = user.email
                entity.phone = user.phone
                entity.location = user.location
                entity.pictureURL = user.pictureURL?.absoluteString ?? ""
            }

            do {
                try self.backgroundContext.save()
            } catch {
                print("Failed to save users: \(error)")
            }
        }
    }

    func fetchUsers() -> [User] {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.map { entity in
                User(
                    id: entity.id ?? "",
                    fullName: entity.fullName ?? "",
                    email: entity.email ?? "",
                    phone: entity.phone ?? "",
                    location: entity.location ?? "",
                    pictureURL: URL(string: entity.pictureURL ?? "")
                )
            }
        } catch {
            print("Failed to fetch users: \(error)")
            return []
        }
    }

    func deleteAllUsers() async {
        await backgroundContext.perform {
            self.deleteAllUsersSync()
        }
    }

    func deleteAllUsersSync() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try backgroundContext.execute(deleteRequest)
        } catch {
            print("Failed to delete users: \(error)")
        }
    }
}
