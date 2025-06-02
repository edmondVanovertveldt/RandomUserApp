//
//  RandomUserResponse.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

struct RandomUserResponse: Decodable {
    let results: [UserDTO]
    let info: Info
}

extension RandomUserResponse {
    struct Info: Decodable {
        let seed: String
        let results: Int
        let page: Int
    }
}
