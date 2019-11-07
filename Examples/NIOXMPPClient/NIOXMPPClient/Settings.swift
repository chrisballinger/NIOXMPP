//
//  Settings.swift
//  NIOXMPPClient
//
//  Created by Chris Ballinger on 11/6/19.
//  Copyright © 2019 ChatSecure. All rights reserved.
//

import Foundation
import NIOXMPP

private let encoder = PropertyListEncoder()
private let decoder = PropertyListDecoder()

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct CodableDefault<T: Codable> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                let value = try? decoder.decode(T.self, from: data) else {
                    return defaultValue
            }
            return value
        }
        set {
            guard let data = try? encoder.encode(newValue) else {
                return
            }
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

enum GlobalSettings {
    @CodableDefault(key: "USER_JID", defaultValue: nil)
    static var myJID: JID?
    
    // FIXME: Move this to keychain
    @UserDefault(key: "USER_PASSWORD", defaultValue: nil)
    static var password: String?
}
