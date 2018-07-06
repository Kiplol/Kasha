//
//  Theme.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/6/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Gestalt

struct Theme: ThemeProtocol {

    let playerBackgroundColor: UIColor
    let playerPrimaryColor: UIColor
    let playerSecondaryColor: UIColor
    let playerDetailColor: UIColor
    
    static let light = Theme(playerBackgroundColor: .white,
                             playerPrimaryColor: .kashaPrimary,
                             playerSecondaryColor: .kashaSecondary,
                             playerDetailColor: .black)
}
