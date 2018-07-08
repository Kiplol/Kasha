//
//  VolumeHUDView.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/8/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class VolumeHUDView: UIView {
    
    private let trackView = UIView()
    private let fillView = UIView()
    private var fillAmount: CGFloat = 0.0 {
        didSet {
            self.showThenHide()
            let width = max(4.0, fillAmount * self.trackView.bounds.size.width - 4.0)
            UIView.animate(withDuration: 0.1) {
                self.fillView.frame.size.width = width
            }
        }
    }
    private var hideTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {
        self.applyAlbumsStyle()
        self.backgroundColor = UIColor.black.alpha(0.6)
        self.trackView.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width - 20.0, height: 6.0)
        self.trackView.backgroundColor = UIColor.black
        self.trackView.roundCorners()
        self.trackView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
        self.trackView.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        self.addSubview(self.trackView)
        
        self.fillView.backgroundColor = UIColor.white
        self.fillView.frame = CGRect(x: 0.0, y: 0.0, width: self.trackView.bounds.size.width - 4.0, height: self.trackView.bounds.size.height - 4.0)
        self.fillView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
        self.fillView.roundCorners()
        self.fillView.center = CGPoint(x: self.trackView.bounds.size.width * 0.5, y: self.trackView.bounds.size.height * 0.5)
        self.trackView.addSubview(self.fillView)
        
        self.alpha = 0.0
        NotificationCenter.default.addObserver(self, selector: #selector(VolumeHUDView.volumeDidChange(_:)),
                                               name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                               object: nil)
    }
    
    private func showThenHide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1.0
        }
        self.hideTimer?.invalidate()
        self.hideTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0.0
            }
        })
    }
    
    class func addAsVolumeView(toWindow window: UIWindow) {
        // Hide system volume view
        let shit = MPVolumeView(frame: .zero)
        shit.sizeToFit()
        shit.alpha = 0.01
        window.addSubview(shit)
        
        let safeAreaInsets = window.safeAreaInsets
        let volumeView = VolumeHUDView(frame: CGRect(x: safeAreaInsets.left + 10.0, y: safeAreaInsets.top + 10.0,
                                                     width: window.bounds.size.width - 20.0 - safeAreaInsets.left - safeAreaInsets.right,
                                                     height: 30.0))
        volumeView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        window.addSubview(volumeView)
    }
    
    // MARK: - Media Notifications
    @objc func volumeDidChange(_ notif: Notification) {
        guard let volume = notif.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float else {
            return
        }
        self.fillAmount = CGFloat(volume)
    }
}
