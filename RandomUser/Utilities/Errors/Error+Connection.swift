//
//  Error+Connection.swift
//  RandomUser
//
//  Created by edmond vanovertveldt on 01/06/2025.
//

import Foundation

extension Error {
    func isConnectivityIssue() -> Bool {
        if let urlError = self as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .timedOut, .networkConnectionLost:
                true
            default:
                false
            }
        } else {
            false
        }
    }
}
