//
//  User.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import Foundation

struct User: Identifiable {
    let id: String
    let fullName: String
    let email: String
    let phone: String
    let location: String
    let pictureURL: URL?
}
