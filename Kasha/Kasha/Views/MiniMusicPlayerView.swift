//
//  MiniMusicControlsView.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/30/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Hue
//import MarqueeLabel
import MediaPlayer
import SwiftIcons
import UIKit

class MiniMusicPlayerView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var imageArtwork: ImageContainerView!
    @IBOutlet weak var labelTitle: UILabel!//MarqueeLabel!
    @IBOutlet weak var labelDetails: UILabel!//MarqueeLabel!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonPause: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var sliderProgress: UISlider!
    
    // MARK: - ivars
    private var displayLink: CADisplayLink?
    private var progress: Double = 0.0 {
        didSet {
            self.sliderProgress.value = Float(progress)
        }
    }
    
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyAlbumsStyle()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MiniMusicPlayerView.playbackStateDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MiniMusicPlayerView.nowPlayingItemDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MiniMusicPlayerView.volumeDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerVolumeDidChange, object: nil)
        self.update(withNowPlayingItem: MediaLibraryHelper.shared.musicPlayer.nowPlayingItem)
        self.update(withPlaybackState: MediaLibraryHelper.shared.musicPlayer.playbackState)
        //@TODO: Volume
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
    
    // MARK: - Playback Progress
    private func startPlaybackTracking() {
        self.stopPlaybackTracking()
        self.displayLink = CADisplayLink(target: self, selector: #selector(MiniMusicPlayerView.displayLinkTick))
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    private func stopPlaybackTracking() {
        self.displayLink?.invalidate()
        self.displayLink = nil
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
    
    @objc func volumeDidChange(_ notif: Notification) {
        
    }
    
    // MARK: -
    private func updateButtons(withColor color: UIColor) {
        let iconSize: CGFloat = 36.0
        self.buttonPrevious.setIcon(icon: .googleMaterialDesign(.skipPrevious), iconSize: iconSize, color: color, backgroundColor: .clear, forState: .normal)
        self.buttonNext.setIcon(icon: .googleMaterialDesign(.skipNext), iconSize: iconSize, color: color, backgroundColor: .clear, forState: .normal)
        self.buttonPlay.setIcon(icon: .googleMaterialDesign(.playArrow), iconSize: iconSize, color: color, backgroundColor: .clear, forState: .normal)
        self.buttonPause.setIcon(icon: .googleMaterialDesign(.pause), iconSize: iconSize, color: color, backgroundColor: .clear, forState: .normal)
    }
    
    private func update(withNowPlayingItem nowPlayingItem: MediaLibraryHelper.Song?) {
        self.updateColors(withNowPlayingItem: nowPlayingItem)
        guard let nowPlayingItem = nowPlayingItem else {
            self.imageArtwork.image = nil
            self.labelTitle.text = "--"
            self.labelDetails.text = "--"
            return
        }
        DispatchQueue.global(qos: .default).async {
            let image = nowPlayingItem.artwork?.image(at: CGSize(width: 54.0, height: 54.0))
            DispatchQueue.main.async {
                self.imageArtwork.image = image ?? #imageLiteral(resourceName: "placeholder-artwork")
            }
        }
        self.labelTitle.text = nowPlayingItem.title ?? "Unknown Song"
        self.labelDetails.text = {
            var details: [String] = []
            if let artist = nowPlayingItem.artist {
                details.append(artist)
            }
            if let album = nowPlayingItem.albumTitle {
                details.append(album)
            }
            return details.joined(separator: " - ")
        }()
    }
    
    private func updateColors(withNowPlayingItem nowPlayingItem: MediaLibraryHelper.Song?) {
        guard let nowPlayingItem = nowPlayingItem else {
            self.resetColors()
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            guard let image = nowPlayingItem.artwork?.image(at: CGSize(width: 54.0, height: 54.0)) else {
                DispatchQueue.main.async {
                    self.resetColors()
                }
                return
            }
            let (background, primary, secondary, detail) = image.colors()
            DispatchQueue.main.async {
                self.backgroundColor = background
                self.sliderProgress.thumbTintColor = primary
                self.sliderProgress.minimumTrackTintColor = secondary
                self.sliderProgress.maximumTrackTintColor = secondary
                self.labelTitle.textColor = primary
                self.labelDetails.textColor = detail
                self.updateButtons(withColor: primary)
            }
        }
    }
    
    private func resetColors() {
        self.backgroundColor = UIColor.white
        self.sliderProgress.thumbTintColor = UIColor.kashaPrimaryColor
        self.sliderProgress.minimumTrackTintColor = UIColor.kashaSecondaryColor
        self.sliderProgress.maximumTrackTintColor = UIColor.kashaSecondaryColor
        self.labelTitle.textColor = UIColor.black
        self.labelDetails.textColor = UIColor.lightGray
        self.updateButtons(withColor: .black)
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
    
    // MARK: - Slider
    @IBAction func sliderValueDidChange(_ sender: UISlider) {
        guard sender == self.sliderProgress else {
            return
        }
        
        guard let nowPlayingItem = MediaLibraryHelper.shared.musicPlayer.nowPlayingItem,
            let songDuration = nowPlayingItem.value(forProperty: MPMediaItemPropertyPlaybackDuration) as? TimeInterval else {
                return
        }
        
        let playbackTime = Double(sender.value) * songDuration
        MediaLibraryHelper.shared.musicPlayer.currentPlaybackTime = playbackTime
    }
}
