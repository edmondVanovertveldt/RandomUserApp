//
//  CoreDataStack.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RandomUserModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()


    // Main UI context (Main Thread)
    lazy var viewContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    // Background context (Private Queue Thread)
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    func saveViewContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed saving viewContext: \(error)")
            }
        }
    }

    func saveBackgroundContext() {
        let context = backgroundContext
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Failed saving backgroundContext: \(error)")
                }
            }
        }
    }
}
