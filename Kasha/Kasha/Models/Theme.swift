//
//  Theme.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/6/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Gestalt

struct Theme: ThemeProtocol {

    let backgroundColor: UIColor
    let textColor: UIColor
    let detailTextColor: UIColor
    let playerTheme: PlayerTheme
    let statusBarStyle: UIStatusBarStyle
    
    struct PlayerTheme {
        let playerBackgroundColor: UIColor
        let playerPrimaryColor: UIColor
        let playerSecondaryColor: UIColor
        let playerDetailColor: UIColor
        
        static let `default` = PlayerTheme(playerBackgroundColor: .white,
                                           playerPrimaryColor: .kashaPrimary,
                                           playerSecondaryColor: .kashaSecondary,
                                           playerDetailColor: .black)
    }
    
    static let light = Theme(backgroundColor: .white, textColor: .black, detailTextColor: .lightGray,
                             playerTheme: .default, statusBarStyle: .default)
    static let dark = Theme(backgroundColor: .kashaDarkBackground, textColor: .white, detailTextColor: .lightGray,
                             playerTheme: .default, statusBarStyle: .lightContent)
    
    func copy(withPlayerTheme playerTheme: PlayerTheme) -> Theme {
        return Theme(backgroundColor: self.backgroundColor, textColor: self.textColor,
                     detailTextColor: self.detailTextColor, playerTheme: playerTheme,
                     statusBarStyle: self.statusBarStyle)
    }
}
