//
//  MusicAwareTabBarController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/30/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class MusicAwareTabBarController: UITabBarController {
    
    public private(set) var miniControls: MiniMusicControlsView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let controls = Bundle.main.loadNibNamed("MiniMusicControlsView", owner: self, options: nil)?[0] as? MiniMusicControlsView else {
                                                        preconditionFailure("Couldn't load MiniMusicControlsView from nib")
        }
        self.miniControls = controls
        self.miniControls.frame = CGRect(x: 10.0, y: self.tabBar.frame.origin.y - 110.0, width: self.view.bounds.size.width - 20.0, height: 100.0)
        self.miniControls.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.view.addSubview(self.miniControls)
    }

}
