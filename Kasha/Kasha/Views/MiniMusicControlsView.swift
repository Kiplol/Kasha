//
//  MiniMusicControlsView.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/30/18.
//  Copyright © 2018 Kip. All rights reserved.
//

//import MarqueeLabel
import MediaPlayer
import SwiftIcons
import UIKit

class MiniMusicControlsView: UIView {

    // MARK: - IBOutlets
    @IBOutlet weak var imageArtwork: ImageContainerView!
    @IBOutlet weak var labelTitle: UILabel!//MarqueeLabel!
    @IBOutlet weak var labelDetails: UILabel!//MarqueeLabel!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyAlbumsStyle()
        
        self.buttonPrevious.setIcon(icon: .googleMaterialDesign(.skipPrevious), forState: .normal)
        self.buttonPlayPause.setIcon(icon: .googleMaterialDesign(.playArrow), forState: .normal)
        self.buttonNext.setIcon(icon: .googleMaterialDesign(.skipNext), forState: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MiniMusicControlsView.playbackStateDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MiniMusicControlsView.nowPlayingItemDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MiniMusicControlsView.volumeDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerVolumeDidChange, object: nil)
        self.update(withNowPlayingItem: MediaLibraryHelper.shared.musicPlayer.nowPlayingItem)
    }

    // MARK: - User Interaction
    @IBAction func previousTapped(_ sender: Any) {
    }
    
    @IBAction func playPauseTapped(_ sender: Any) {
        if MediaLibraryHelper.shared.musicPlayer.playbackState == .playing {
            MediaLibraryHelper.shared.pause()
        } else {
            MediaLibraryHelper.shared.play()
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
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
    private func update(withNowPlayingItem nowPlayingItem: MediaLibraryHelper.Song?) {
        guard let nowPlayingItem = nowPlayingItem else {
            self.imageArtwork.image = nil
            self.labelTitle.text = "--"
            self.labelDetails.text = "--"
            return
        }
        DispatchQueue.global(qos: .default).async {
            let image = nowPlayingItem.artwork?.image(at: CGSize(width: 54.0, height: 54.0))
            DispatchQueue.main.async {
                self.imageArtwork.image = image
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
    
    private func update(withPlaybackState playbackState: MPMusicPlaybackState) {
        switch playbackState {
        case .playing:
            self.buttonPlayPause.setIcon(icon: .googleMaterialDesign(.pause), forState: .normal)
        case .paused, .stopped:
            self.buttonPlayPause.setIcon(icon: .googleMaterialDesign(.playArrow), forState: .normal)
        default:
            break
        }
    }
}
