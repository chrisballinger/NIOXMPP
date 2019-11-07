//
//  ViewController.swift
//  NIOXMPPClient
//
//  Created by Chris Ballinger on 11/6/19.
//  Copyright © 2019 ChatSecure. All rights reserved.
//

import UIKit
import SwiftUI
import NIOXMPP

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(didTapSettings(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(didTapConnect(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = GlobalSettings.myJID?.bare
    }

}

private extension ViewController {
    @objc func didTapSettings(_ sender: UIBarButtonItem) {
        let userView = UserView(bareJID: GlobalSettings.myJID?.bare ?? "", password: GlobalSettings.password ?? "") { [weak self] (bareJID, password) in
            GlobalSettings.myJID = JID(bareJID: bareJID)
            GlobalSettings.password = password
            self?.navigationController?.popViewController(animated: true)
        }
        let userVC = UIHostingController(rootView: userView)
        navigationController?.pushViewController(userVC, animated: true)
    }
    
    @objc func didTapConnect(_ sender: UIBarButtonItem) {
        
    }
}
