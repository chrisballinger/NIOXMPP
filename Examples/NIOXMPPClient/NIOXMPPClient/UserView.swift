//
//  UserView.swift
//  NIOXMPPClient
//
//  Created by Chris Ballinger on 11/6/19.
//  Copyright © 2019 ChatSecure. All rights reserved.
//

import SwiftUI

struct UserView: View {
    @State var bareJID: String = ""
    @State var password: String = ""
    var didTapSave: ((_ bareJID: String, _ password: String) -> Void)?
    
    var body: some View {
        Form {
            Section(header: Text("Username")) {
                TextField("user@example.com", text: $bareJID)
            }
            Section(header: Text("Password")) {
                SecureField("", text: $password)
            }
            Button("Save") {
                self.didTapSave?(self.bareJID, self.password)
            }
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserView()
                .previewLayout(.sizeThatFits)
            UserView(bareJID: "user@example.com", password: "secret")
                .previewLayout(.sizeThatFits)
        }
    }
}
