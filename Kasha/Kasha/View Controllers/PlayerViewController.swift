//
//  PlayerViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/5/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import DeckTransition
import Gestalt
import MediaPlayer
import UIKit

class PlayerViewController: KashaViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageArtwork: ImageContainerView!
    @IBOutlet weak var artworkContainer: UIView!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonPause: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonShuffleIsOff: UIButton!
    @IBOutlet weak var buttonShuffleIsOn: UIButton!
    @IBOutlet weak var buttonMore: UIButton!
    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet weak var labelSongTitle: UILabel!
    @IBOutlet weak var labelSongInfo: UILabel!
    @IBOutlet weak var waveContainer: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var labelTimeRemaining: UILabel!
    @IBOutlet weak var labelTimeElapsed: UILabel!
    @IBOutlet weak var volumeView: MPVolumeView!
    @IBOutlet weak var wavesView: WavesView!
    
    // MARK: - ivars
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
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
        self.topBackgroundView.backgroundColor = theme.backgroundColor
        self.artworkContainer.backgroundColor = theme.backgroundColor
        self.labelSongTitle.textColor = theme.textColor
        self.labelSongInfo.textColor = theme.detailTextColor
        
        let shadowColor = self.view.backgroundColor!.isDark ? UIColor.white : UIColor.black
        let playPauseBackgoundColor = theme.playerTheme.playerDetailColor.isDark ? UIColor.white : UIColor.black
        [self.buttonPause, self.buttonPlay].forEach {
            $0?.backgroundColor = playPauseBackgoundColor.alpha(0.7)
        }
        self.allButtons.forEach {
            $0.tintColor = theme.playerTheme.playerDetailColor
            $0.layer.shadowColor = shadowColor.cgColor
        }
        self.wavesView.waveColor = theme.playerTheme.playerBackgroundColor
        self.scrollView.backgroundColor = theme.playerTheme.playerBackgroundColor
        
//        self.progressSlider.thumbTintColor = theme.playerDetailColor
        self.progressSlider.maximumTrackTintColor = theme.playerTheme.playerPrimaryColor
        self.progressSlider.minimumTrackTintColor = theme.playerTheme.playerPrimaryColor
        
        let labelsShadowColor = theme.playerTheme.playerBackgroundColor.isDark ? UIColor.black.alpha(0.3) : UIColor.white.alpha(0.3)
        [self.labelTimeRemaining, self.labelTimeElapsed].forEach {
            $0?.textColor = theme.playerTheme.playerPrimaryColor
            $0?.shadowColor = labelsShadowColor
        }
        
        self.volumeView.tintColor = theme.playerTheme.playerDetailColor
    }
    
    override func allowsSearch() -> Bool {
        return false
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
        self.updateWithShuffle(isOn: MediaLibraryHelper.shared.isShuffleOn)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let statusBarStyle = (ThemeManager.default.theme as? Theme)?.statusBarStyle {
            UIApplication.shared.statusBarStyle = statusBarStyle
        }
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
    
    @IBAction func shuffleIsOnTapped(_ sender: Any) {
        self.updateWithShuffle(isOn: MediaLibraryHelper.shared.toggleShuffle())
    }
    
    @IBAction func shuffeIsOffTapped(_ sender: Any) {
        self.updateWithShuffle(isOn: MediaLibraryHelper.shared.toggleShuffle())
    }
    
    @IBAction func moreTapped(_ sender: Any) {
        guard let nowPlayingItem = MediaLibraryHelper.shared.musicPlayer.nowPlayingItem else {
            return
        }
        let alert = MediaLibraryHelper.shared.actionsAlert(forSong: nowPlayingItem, withViewController: self)
        self.present(alert, animated: true, completion: nil)
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
            if let album = nowPlayingItem.albumTitle, !album.isEmpty {
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
    
    private func updateWithShuffle(isOn: Bool) {
        self.buttonShuffleIsOn.isHidden = !isOn
        self.buttonShuffleIsOff.isHidden = !self.buttonShuffleIsOn.isHidden
    }
    
    private func startPlaybackTracking() {
        self.buttonPlay.isHidden = true
        self.buttonPause.isHidden = false
        self.startWaveView()
        self.startDisplayLink()
    }
    
    private func stopPlaybackTracking() {
        self.buttonPlay.isHidden = false
        self.buttonPause.isHidden = true
        self.stopWaveView()
        self.stopDisplayLink()
    }
    
    // MARK: - DisplayLink
    private func startDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(PlayerViewController.displayLinkTick))
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    private func stopDisplayLink() {
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
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        self.labelTimeElapsed.text = formatter.string(from: currentTime)
        self.labelTimeRemaining.text = "-\(formatter.string(from: songDuration - currentTime) ?? "")"
    }
    
    // MARK: - Wave View
    private func stopWaveView() {
        self.wavesView.stop()
    }
    
    private func startWaveView() {
        self.wavesView.start()
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
