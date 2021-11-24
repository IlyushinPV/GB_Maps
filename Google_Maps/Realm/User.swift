//
//  User.swift
//  Google_Maps
//
//  Created by iMac on 14.11.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login = ""
    @objc dynamic var password = ""

    override static func primaryKey() -> String? {
            return "login"
        }
}
