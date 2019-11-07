//
//  JID.swift
//  NIOXMPP
//
//  Created by Chris Ballinger on 11/6/19.
//  Copyright © 2019 ChatSecure. All rights reserved.
//

import Foundation

public struct JID {
    public var user: String?
    public var domain: String
    public var resource: String?
    
    public init(user: String?,
                domain: String,
                resource: String?) {
        self.user = user
        self.domain  = domain
        self.resource = resource
    }
    
    public init?(bareJID: String) {
        let components = bareJID.components(separatedBy: "@")
        guard let user = components.first, let domain = components.last else {
            return nil
        }
        self.user = user
        self.domain = domain
    }
    
    public var bare: String {
        "\(user ?? "")@\(domain)"
    }
}

extension JID: Hashable, Codable {}
