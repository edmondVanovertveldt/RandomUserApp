//
//  UserDefaultsUserSettings.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import Foundation

final class UserDefaultsUserSettings: UserSettings {
    private let nextPageKey = "nextPage"
    private let seedKey = "seed"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var nextPage: Int? {
        get {
            let value = defaults.integer(forKey: nextPageKey)
            return value == 0 ? nil : value
        }
        set {
            defaults.set(newValue, forKey: nextPageKey)
        }
    }

    var seed: String? {
        get {
            let seed = defaults.string(forKey: seedKey)
            return seed
        }
        set {
            defaults.set(newValue, forKey: seedKey)
        }
    }
}
