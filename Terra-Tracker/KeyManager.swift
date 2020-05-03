//
//  KeyManager.swift
//  Terra-Tracker
//
//  Created by 塩塚 弘樹 on 2020/05/02.
//  Copyright © 2020 塩塚 弘樹. All rights reserved.
//

import Foundation

struct KeyManager {

    private let keyFilePath = Bundle.main.path(forResource: "APIKey", ofType: "plist")

    func getKeys() -> NSDictionary? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        return NSDictionary(contentsOfFile: keyFilePath)
    }

    func getValue(key: String) -> AnyObject? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys[key]! as AnyObject
    }
}
