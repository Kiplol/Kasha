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

    // MARK: - IBOutlets
    @IBOutlet weak var labelExplanation: UILabel!
    @IBOutlet weak var buttonSettings: UIButton! {
        didSet {
            self.buttonSettings.applyAlbumsStyle()
        }
    }
    @IBOutlet var unauthorizedViews: [UIView]!
    
    // MARK: - KashaViewController
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        self.labelExplanation.textColor = theme.textColor
        self.buttonSettings.backgroundColor = theme.primaryAccentColor
        self.buttonSettings.setTitleColor((theme.primaryAccentColor.isDark ? .white: .black), for: .normal)
    }
    
    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MPMediaLibrary.requestAuthorization { authorizationStatus in
            print(authorizationStatus)
            switch authorizationStatus {
            case .authorized:
                DispatchQueue.main.async {
                    AppDelegate.instance.enterApp()
                    self.unauthorizedViews.forEach { $0.isHidden = true }
                }
            default:
                DispatchQueue.main.async {
                    self.unauthorizedViews.forEach { $0.isHidden = false }
                }
            }
        }
    }
    
    // MARK: - User Interaction
    @IBAction func settingsTapped(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
    
}
