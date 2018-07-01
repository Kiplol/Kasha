//
//  MusicAwareTabBarController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/30/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

protocol MusicAwareTabBarControllerListener {
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController,
                                   willMoveMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView,
                                   toFrame frame: CGRect)
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController,
                                   didShowMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView)
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController,
                                   didHideMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView)
}

class MusicAwareTabBarController: UITabBarController {
    
    public private(set) var miniPlayer: MiniMusicPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let player = Bundle.main.loadNibNamed("MiniMusicPlayerView", owner: self, options: nil)?[0] as? MiniMusicPlayerView else {
                                                        preconditionFailure("Couldn't load MiniMusicControlsView from nib")
        }
        self.miniPlayer = player
        self.miniPlayer.frame.origin.x = 10.0
        self.miniPlayer.frame.size.width = self.view.bounds.size.width - 20.0
        self.miniPlayer.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.view.addSubview(self.miniPlayer)
        self.positionMiniPlayer(forPlaybackState: MediaLibraryHelper.shared.musicPlayer.playbackState, animated: false)
    }
    
    private func positionMiniPlayer(forPlaybackState playbackState: MPMusicPlaybackState, animated: Bool = true) {
        switch playbackState {
        case .playing, .paused:
            self.showMiniPlayer(animated)
        default:
            self.hideMiniPlayer(animated)
        }
    }
    
    private func hideMiniPlayer(_ animated: Bool = true) {
        var newFrame = self.miniPlayer.frame
        newFrame.origin.y = self.view.bounds.size.height + (AppDelegate.instance.window?.safeAreaInsets.bottom ?? 0.0)
        self.informViewControllersOfMiniPlayerFrameChange(newFrame)
        let animation = {
            self.miniPlayer.frame = newFrame
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: animation) { _ in
                self.informViewControllersOfMiniPlayerDidHide()
            }
        } else {
            animation()
            self.informViewControllersOfMiniPlayerDidHide()
        }
    }
    
    private func showMiniPlayer(_ animated: Bool = true) {
        var newFrame = self.miniPlayer.frame
        newFrame.origin.y = self.tabBar.frame.origin.y - self.miniPlayer.bounds.size.height - 10.0 - (AppDelegate.instance.window?.safeAreaInsets.bottom ?? 0.0)
        self.informViewControllersOfMiniPlayerFrameChange(newFrame)
        let animation = {
            self.miniPlayer.frame = newFrame
        }
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [.beginFromCurrentState], animations: animation, completion: { _ in
                self.informViewControllersOfMiniPlayerDidShow()
            })
        } else {
            animation()
            self.informViewControllersOfMiniPlayerDidShow()
        }
    }
    
    private func informViewControllersOfMiniPlayerFrameChange(_ frame: CGRect) {
        self.viewControllers?.forEach {
            if let listener = $0 as? MusicAwareTabBarControllerListener {
                listener.musicAwareTabBarController(self, willMoveMiniMusicPlayerView: self.miniPlayer, toFrame: frame)
            }
        }
    }
    
    private func informViewControllersOfMiniPlayerDidShow() {
        self.viewControllers?.forEach {
            if let listener = $0 as? MusicAwareTabBarControllerListener {
                listener.musicAwareTabBarController(self, didShowMiniMusicPlayerView: self.miniPlayer)
            }
        }
    }
    
    private func informViewControllersOfMiniPlayerDidHide() {
        self.viewControllers?.forEach {
            if let listener = $0 as? MusicAwareTabBarControllerListener {
                listener.musicAwareTabBarController(self, didHideMiniMusicPlayerView: self.miniPlayer)
            }
        }
    }
}

extension UINavigationController: MusicAwareTabBarControllerListener {
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController, willMoveMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView, toFrame frame: CGRect) {
        self.viewControllers.forEach {
            if let listener = $0 as? MusicAwareTabBarControllerListener {
                listener.musicAwareTabBarController(tabBarController, willMoveMiniMusicPlayerView: miniMusicPlayerView, toFrame: frame)
            }
        }
    }
    
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController, didShowMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView) {
        self.viewControllers.forEach {
            if let listener = $0 as? MusicAwareTabBarControllerListener {
                listener.musicAwareTabBarController(tabBarController, didShowMiniMusicPlayerView: miniMusicPlayerView)
            }
        }
    }
    
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController, didHideMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView) {
        self.viewControllers.forEach {
            if let listener = $0 as? MusicAwareTabBarControllerListener {
                listener.musicAwareTabBarController(tabBarController, didHideMiniMusicPlayerView: miniMusicPlayerView)
            }
        }
    }
}
