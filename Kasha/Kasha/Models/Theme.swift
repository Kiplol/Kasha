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
    let playerTheme: PlayerTheme
    
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
    
    static let light = Theme(backgroundColor: .white,
                             playerTheme: .default)
    
    func copy(withPlayerTheme playerTheme: PlayerTheme) -> Theme {
        return Theme(backgroundColor: self.backgroundColor, playerTheme: playerTheme)
    }
}
