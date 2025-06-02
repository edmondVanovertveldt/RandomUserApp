//
//  UserDTO.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import Foundation

struct UserDTO: Decodable {
    let login: Login
    let name: Name
    let email: String
    let phone: String
    let location: Location
    let picture: Picture
}

extension UserDTO {
    struct Login: Decodable {
        let uuid: String
    }

    struct Name: Decodable {
        let title: String
        let first: String
        let last: String
    }

    struct Location: Decodable {
        let street: Street
        let city: String
        let state: String
        let country: String
        let postcode: String?

        enum CodingKeys: String, CodingKey {
            case street, city, state, country, postcode
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            street = try container.decode(Street.self, forKey: .street)
            city = try container.decode(String.self, forKey: .city)
            state = try container.decode(String.self, forKey: .state)
            country = try container.decode(String.self, forKey: .country)

            if let postcodeInt = try? container.decode(Int.self, forKey: .postcode) {
                postcode = String(postcodeInt)
            } else if let postcodeString = try? container.decode(String.self, forKey: .postcode) {
                postcode = postcodeString
            } else {
                postcode = nil
            }
        }
    }

    struct Picture: Decodable {
        let large: String
        let thumbnail: String
    }
}

extension UserDTO.Location {
    struct Street: Decodable {
        let number: Int
        let name: String
    }
}

// MARK: - DOMAIN

extension User {
    init(dto: UserDTO) {
        self.id = dto.login.uuid
        self.fullName = "\(dto.name.title) \(dto.name.first) \(dto.name.last)"
        self.email = dto.email
        self.phone = dto.phone
        self.location = "\(dto.location.street.number) rue \(dto.location.street.name), \(dto.location.postcode ?? "") \(dto.location.city) \(dto.location.country)"
        self.pictureURL = URL(string: dto.picture.large)
    }
}
