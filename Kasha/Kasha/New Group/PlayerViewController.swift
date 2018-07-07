//
//  PlayerViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/5/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit
import YXWaveView

class PlayerViewController: KashaViewController {
    
    private static let stoppedWaveHeight: CGFloat = 5.0
    private static let stoppedWaveSpeed: CGFloat = 0.6
    private static let playingWaveHeightMax: CGFloat = 15.0
    private static let playingWaveHeightMin: CGFloat = 10.0
    private static let playingWaveSpeed: CGFloat = 1.0

    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageArtwork: ImageContainerView!
    @IBOutlet weak var artworkContainer: UIView!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonPause: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet weak var labelSongTitle: UILabel!
    @IBOutlet weak var labelSongInfo: UILabel!
    @IBOutlet weak var waveContainer: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var labelTimeRemaining: UILabel!
    @IBOutlet weak var labelTimeElapsed: UILabel!
    @IBOutlet weak var volumeView: MPVolumeView!
    
    // MARK: - ivars
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private let waveView: YXWaveView = YXWaveView(frame: .zero, color: UIColor.kashaPrimary)
    private var progress: Double = 0.0 {
        didSet {
            guard self.isViewLoaded else {
                return
            }
            self.progressSlider.value = Float(self.progress)
        }
    }
    private var displayLink: CADisplayLink?
    
    // MARK: - KashaViewController
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        let shadowColor = self.view.backgroundColor!.isDark ? UIColor.white : UIColor.black
        let playPauseBackgoundColor = theme.playerDetailColor.isDark ? UIColor.white : UIColor.black
        [self.buttonPause, self.buttonPlay].forEach {
            $0?.backgroundColor = playPauseBackgoundColor.alpha(0.7)
        }
        self.allButtons.forEach {
            $0.tintColor = theme.playerDetailColor
            $0.layer.shadowColor = shadowColor.cgColor
        }
        self.waveView.realWaveColor = theme.playerBackgroundColor
        self.waveView.maskWaveColor = theme.playerBackgroundColor.alpha(0.4)
        self.scrollView.backgroundColor = theme.playerBackgroundColor
        
//        self.progressSlider.thumbTintColor = theme.playerDetailColor
        self.progressSlider.maximumTrackTintColor = theme.playerPrimaryColor
        self.progressSlider.minimumTrackTintColor = theme.playerPrimaryColor
        
        let labelsShadowColor = theme.playerBackgroundColor.isDark ? UIColor.black.alpha(0.3) : UIColor.white.alpha(0.3)
        [self.labelTimeRemaining, self.labelTimeElapsed].forEach {
            $0?.textColor = theme.playerPrimaryColor
            $0?.shadowColor = labelsShadowColor
        }
        
        self.volumeView.tintColor = theme.playerPrimaryColor
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        
        self.imageArtwork.layer.cornerRadius = 15.0
        self.imageArtwork.layer.shadowRadius = 10.0
        self.artworkContainer.applyAlbumsStyle()
        self.artworkContainer.layer.cornerRadius = 20.0
        self.artworkContainer.layer.shadowRadius = 15.0
        
        self.waveView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.waveContainer.addSubview(self.waveView)
        self.waveView.frame = self.waveContainer.bounds
        self.waveView.start()
        
        self.progressSlider.setThumbImage(#imageLiteral(resourceName: "Slider-Thumb"), for: .normal)
        self.progressSlider.setThumbImage(#imageLiteral(resourceName: "Slider-Thumb"), for: .highlighted)
        self.progressSlider.setThumbImage(#imageLiteral(resourceName: "Slider-Thumb"), for: .selected)

        self.volumeView.setRouteButtonImage(#imageLiteral(resourceName: "airplay"), for: .normal)
        self.volumeView.showsVolumeSlider = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.playbackStateDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerViewController.nowPlayingItemDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
        self.update(withNowPlayingItem: MediaLibraryHelper.shared.musicPlayer.nowPlayingItem)
        self.update(withPlaybackState: MediaLibraryHelper.shared.musicPlayer.playbackState)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.update(withNowPlayingItem: MediaLibraryHelper.shared.musicPlayer.nowPlayingItem)
    }
    
    // MARK: - User Interaction
    @IBAction func closeTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func previousTapped(_ sender: Any) {
        MediaLibraryHelper.shared.previous()
    }
    
    @IBAction func playTapped(_ sender: Any) {
        MediaLibraryHelper.shared.play()
    }
    
    @IBAction func pauseTapped(_ sender: Any) {
        MediaLibraryHelper.shared.pause()
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        MediaLibraryHelper.shared.next()
    }
    
    // MARK: - Helpers
    private func update(withNowPlayingItem nowPlayingItem: MediaLibraryHelper.Song?) {
        guard let nowPlayingItem = nowPlayingItem else {
            self.labelSongInfo.text = "---"
            self.labelSongTitle.text = "---"
            self.imageArtwork.image = #imageLiteral(resourceName: "placeholder-artwork")
            return
        }
        
        self.labelSongTitle.text = nowPlayingItem.title
        self.labelSongInfo.text = {
            var components: [String] = []
            if let artist = nowPlayingItem.artist {
                components.append(artist)
            }
            if let album = nowPlayingItem.albumTitle {
                components.append(album)
            }
            return components.joined(separator: " - ")
        }()
        
        DispatchQueue.global(qos: .default).async {
            let image = nowPlayingItem.artwork?.image(at: CGSize(width: 80.0, height: 80.0))
            DispatchQueue.main.async {
                self.imageArtwork.image = image ?? #imageLiteral(resourceName: "placeholder-artwork")
            }
        }
    }
    
    private func update(withPlaybackState playbackState: MPMusicPlaybackState) {
        switch playbackState {
        case .playing:
            self.startPlaybackTracking()
        default:
            self.stopPlaybackTracking()
        }
    }
    
    private func startPlaybackTracking() {
        self.buttonPlay.isHidden = true
        self.buttonPause.isHidden = false
        self.startWaveView()
        self.startDisplayLink()
    }
    
    private func startDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(PlayerViewController.displayLinkTick))
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    private func stopPlaybackTracking() {
        self.buttonPlay.isHidden = false
        self.buttonPause.isHidden = true
        self.stopWaveView()
        self.stopDisplayLink()
    }
    
    private func stopDisplayLink() {
        self.displayLink?.invalidate()
        self.displayLink = nil
    }
    
    // MARK: - DisplayLink
    @objc func displayLinkTick() {
        guard let nowPlayingItem = MediaLibraryHelper.shared.musicPlayer.nowPlayingItem,
            let songDuration = nowPlayingItem.value(forProperty: MPMediaItemPropertyPlaybackDuration) as? TimeInterval else {
                self.progress = 0.0
                return
        }
        
        let currentTime = MediaLibraryHelper.shared.musicPlayer.currentPlaybackTime
        let progress = currentTime / songDuration
        self.progress = progress
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        self.labelTimeElapsed.text = formatter.string(from: currentTime)
        self.labelTimeRemaining.text = "-\(formatter.string(from: songDuration - currentTime) ?? "")"
    }
    
    // MARK: - Wave View
    private func stopWaveView() {
        self.waveView.waveHeight = PlayerViewController.stoppedWaveHeight
        self.waveView.waveSpeed = PlayerViewController.stoppedWaveSpeed
        self.waveView.start()
    }
    
    private func startWaveView() {
        let waveHeight = CGFloat.random(min: PlayerViewController.playingWaveHeightMin,
                                        max: PlayerViewController.playingWaveHeightMax)
        self.waveView.waveHeight = waveHeight
        self.waveView.waveSpeed = PlayerViewController.playingWaveSpeed
        self.waveView.start()
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [weak self] in
//            if MediaLibraryHelper.shared.musicPlayer.playbackState == .playing {
//                self?.startWaveView()
//            }
//        })
    }
    
    // MARK: - Slider
    @IBAction func sliderValueDidChange(_ sender: UISlider) {
        guard sender == self.progressSlider else {
            return
        }
        
        guard let nowPlayingItem = MediaLibraryHelper.shared.musicPlayer.nowPlayingItem,
            let songDuration = nowPlayingItem.value(forProperty: MPMediaItemPropertyPlaybackDuration) as? TimeInterval else {
                return
        }
        
        let playbackTime = Double(sender.value) * songDuration
        MediaLibraryHelper.shared.musicPlayer.currentPlaybackTime = playbackTime
        self.progress = Double(sender.value)
    }
    
    @IBAction func sliderBeganSliding(_ sender: Any) {
        self.stopDisplayLink()
    }
    
    @IBAction func sliderEndedSliding(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            if MediaLibraryHelper.shared.musicPlayer.playbackState == .playing {
                self.startDisplayLink()
            }
        })
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
}
