//
//  AppDelegate.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/4/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import BDKCollectionIndexView
import Gestalt
import Hue
import MediaPlayer
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - ivars
    class var instance: AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            preconditionFailure("What on Earth?")
        }
        return appDelegate
    }
    var safeAreaInsets: UIEdgeInsets {
        return self.window?.safeAreaInsets ?? UIEdgeInsets.zero
    }
    
    var window: UIWindow?

    // MARK: - UIApplicationDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.setupAppearance()
        self.initializeThirdPartyLibraries()
        MediaLibraryHelper.shared.musicPlayer.beginGeneratingPlaybackNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Session Control
    func enterApp() {
        DispatchQueue.main.async {
            guard let rootTabBarController = UIStoryboard(name: "Main", bundle: Bundle.main)
                .instantiateViewController(withIdentifier: "rootTabBarController") as? UITabBarController else {
                    return
            }
            self.window?.rootViewController = rootTabBarController
            if let window = self.window {
                VolumeHUDView.addAsVolumeView(toWindow: window)
            }
        }
    }
    
    // MARK: - Private
    func setupAppearance() {
        // Window
        self.window?.tintColor = UIColor.kashaPrimary

        // Navigation Bar
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.barTintColor = UIColor.white
        navigationBarAppearance.prefersLargeTitles = true
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.backgroundColor = .white
        
        UINavigationBar.appearance().largeTitleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.kashaPrimary]
        
        // Tab Bar
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.isTranslucent = false
        
        // Collection Index View
        BDKCollectionIndexView.appearance().tintColor = UIColor.kashaPrimary
        
        // Slider
//        UISlider.appearance().thumbTintColor = UIColor.kashaPrimary
//        UISlider.appearance().minimumTrackTintColor = UIColor.kashaSecondary
//        UISlider.appearance().maximumTrackTintColor = UIColor.kashaSecondary
        let volumeSliderAppearance = UISlider.appearance(whenContainedInInstancesOf: [MPVolumeView.self])
        volumeSliderAppearance.maximumValueImage = #imageLiteral(resourceName: "volume_up")
        volumeSliderAppearance.minimumValueImage = #imageLiteral(resourceName: "volume_down")
    }
    
    private func initializeThirdPartyLibraries() {
        // App Center
        MSAppCenter.start("0a537f68-01d6-4054-b509-98c429fbbee2", withServices: [
            MSAnalytics.self,
            MSCrashes.self
            ])
        
        // Gestalt
        ThemeManager.default.theme = Theme.light
    }

}
