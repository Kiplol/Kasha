//
//  MiniMusicControlsView.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/30/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Gestalt
import Hue
import MediaPlayer
import UIKit

class MiniMusicPlayerView: UIView {
    
    private static let shouldThemeFromMusic = false

    // MARK: - IBOutlets
    @IBOutlet weak var imageArtwork: ImageContainerView!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonPause: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonExpand: UIButton!
    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet weak var fillContainer: UIView!
    @IBOutlet weak var fillView: UIView!
    @IBOutlet weak var constraintFillWidth: NSLayoutConstraint!
    
    // MARK: - ivars
    private var displayLink: CADisplayLink?
    private var progress: Double = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.constraintFillWidth.constant = CGFloat(self.progress) * self.bounds.size.width
                self.layoutIfNeeded()
            }
        }
    }
    var expandTapAction: ((UIButton) -> Void)?
    
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyAlbumsStyle()
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 20.0
        self.fillContainer.layer.cornerRadius = self.cornerRadius
        
        NotificationCenter.default.addObserver(self, selector: #selector(MiniMusicPlayerView.playbackStateDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MiniMusicPlayerView.nowPlayingItemDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        self.update(withNowPlayingItem: MediaLibraryHelper.shared.musicPlayer.nowPlayingItem)
        self.update(withPlaybackState: MediaLibraryHelper.shared.musicPlayer.playbackState)
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            DispatchQueue.main.async {
                if MiniMusicPlayerView.shouldThemeFromMusic {
                    themeable.backgroundColor = theme.playerTheme.playerBackgroundColor
                    themeable.fillView.backgroundColor = theme.playerTheme.playerPrimaryColor
                    let buttonShadowColor = self.fillView.backgroundColor!.isDark ? UIColor.white : UIColor.black
                    themeable.updateButtons(withColor: theme.playerTheme.playerDetailColor, andShadowColor: buttonShadowColor)
                } else {
                    themeable.backgroundColor = theme.backgroundColor
                    themeable.fillView.backgroundColor = theme.primaryAccentColor
                    let buttonShadowColor = self.fillView.backgroundColor!.isDark ? UIColor.white : UIColor.black
                    let buttonColor = buttonShadowColor.isDark ? UIColor.white : UIColor.black
                    themeable.updateButtons(withColor: buttonColor, andShadowColor: buttonShadowColor)
                }
            }
        }
    }

    // MARK: - User Interaction
    @IBAction func previousTapped(_ sender: Any) {
        MediaLibraryHelper.shared.previous()
    }
    
    @IBAction func playTapped(_ sender: Any) {
        if MediaLibraryHelper.shared.musicPlayer.playbackState != .playing {
            MediaLibraryHelper.shared.play()
        }
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        if MediaLibraryHelper.shared.musicPlayer.playbackState == .playing {
            MediaLibraryHelper.shared.pause()
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        MediaLibraryHelper.shared.next()
    }
    
    @IBAction func expandTapped(_ sender: Any) {
        expandTapAction?(self.buttonExpand)
    }
    // MARK: - Playback Progress
    private func startPlaybackTracking() {
        self.stopPlaybackTracking()
        self.displayLink = CADisplayLink(target: self, selector: #selector(MiniMusicPlayerView.displayLinkTick))
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    private func stopPlaybackTracking() {
        self.displayLink?.invalidate()
        self.displayLink = nil
//        self.progress = 0.0
    }
    
    @objc func displayLinkTick() {
        guard let nowPlayingItem = MediaLibraryHelper.shared.musicPlayer.nowPlayingItem,
            let songDuration = nowPlayingItem.value(forProperty: MPMediaItemPropertyPlaybackDuration) as? TimeInterval else {
                self.progress = 0.0
                return
        }
        
        let currentTime = MediaLibraryHelper.shared.musicPlayer.currentPlaybackTime
        let progress = currentTime / songDuration
        self.progress = progress
    }
    
    // MARK: - Media Notifications
    @objc func playbackStateDidChange(_ notif: Notification) {
        guard let player = notif.object as? MPMusicPlayerController else {
            return
        }
        self.update(withPlaybackState: player.playbackState)
    }
    
    @objc func nowPlayingItemDidChange(_ notif: Notification) {
        guard let player = notif.object as? MPMusicPlayerController else {
            return
        }
        self.update(withNowPlayingItem: player.nowPlayingItem)
    }
    
    // MARK: -
    private func updateButtons(withColor color: UIColor, andShadowColor shadowColor: UIColor = .black) {
        [self.buttonPause, self.buttonPlay].forEach { $0?.backgroundColor = shadowColor.alpha(0.7) }
        self.allButtons.forEach {
            $0.tintColor = color
            $0.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    private func update(withNowPlayingItem nowPlayingItem: MediaLibraryHelper.Song?) {
        guard let nowPlayingItem = nowPlayingItem else {
            self.imageArtwork.image = #imageLiteral(resourceName: "placeholder-artwork")
            return
        }
        DispatchQueue.global(qos: .default).async {
            let image = nowPlayingItem.artwork?.image(at: CGSize(width: 54.0, height: 54.0))
            DispatchQueue.main.async {
                self.imageArtwork.image = image ?? #imageLiteral(resourceName: "placeholder-artwork")
            }
        }
    }
    
    private func update(withPlaybackState playbackState: MPMusicPlaybackState) {
        switch playbackState {
        case .playing:
            self.startPlaybackTracking()
            self.buttonPlay.isHidden = true
            self.buttonPause.isHidden = false
        default:
            self.stopPlaybackTracking()
            self.buttonPlay.isHidden = false
            self.buttonPause.isHidden = true
        }
    }
}
