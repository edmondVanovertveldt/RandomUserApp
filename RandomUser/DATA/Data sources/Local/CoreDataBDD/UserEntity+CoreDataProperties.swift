//
//  UserEntity+CoreDataProperties.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var fullName: String?
    @NSManaged public var email: String?
    @NSManaged public var phone: String?
    @NSManaged public var location: String?
    @NSManaged public var pictureURL: String?

}

extension UserEntity : Identifiable {

}
