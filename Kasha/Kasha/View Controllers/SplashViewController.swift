//
//  SplashViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/6/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class SplashViewController: KashaViewController {

    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MPMediaLibrary.requestAuthorization { authorizationStatus in
            print(authorizationStatus)
            switch authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    AppDelegate.instance.enterApp()
                }
            default:
                break
            }
        }
    }
    
}
