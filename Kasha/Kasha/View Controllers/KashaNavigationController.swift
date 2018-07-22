//
//  KashaNavigationController.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/6/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Gestalt
import UIKit

class KashaNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            themeable.view.backgroundColor = theme.backgroundColor
        }
//        self.navigationBar.layer.shadowColor = UIColor.black.cgColor
//        self.navigationBar.layer.shadowOpacity = 0.1
//        self.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
//        self.navigationBar.layer.shadowRadius = 7.0
    }

}
