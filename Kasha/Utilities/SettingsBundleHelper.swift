//
//  SettingsBundleHelper.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/19/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Gestalt
import UIKit

class SettingsBundleHelper: NSObject {
    
    static let shared = SettingsBundleHelper()
    
    var isDarkModeOn: Bool {
        return UserDefaults.standard.bool(forKey: Key.isDarkModeOn)
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsBundleHelper.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    struct Key {
        static let isDarkModeOn = "DARK_MODE_ON"
    }
    
    @objc func defaultsChanged() {
        let theme = SettingsBundleHelper.shared.isDarkModeOn ? Theme.dark : Theme.light
        ThemeManager.default.theme = theme
    }

}
