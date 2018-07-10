//
//  SongTableViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/24/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class KashaTableViewCell: UITableViewCell, SelfSizing {
    
    enum SelectionStyle {
        case `default`
        case nowPlaying
    }

    // MARK: - IBOutlets
    @IBOutlet weak var imageAlbum: ImageContainerView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nowPlayingView: UIView!
    
    // MARK: - ivars
    var selectionDisplayStyle: SelectionStyle = .default
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.applyAlbumsStyle()
        self.containerView.layer.shadowOpacity = 0.0
        self.nowPlayingView.layer.cornerRadius = 2.0
        self.labelTitle.text = nil
        self.labelDetails.text = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        switch self.selectionDisplayStyle {
        case .nowPlaying:
            let animations = {
                self.containerView.layer.shadowOpacity = selected ? 0.1 : 0.0
                self.nowPlayingView.isHidden = !selected
            }
            if animated {
                UIView.animate(withDuration: 0.2, animations: animations)
            } else {
                animations()
            }
        default:
            super.setSelected(selected, animated: animated)
        }
    }
    
    func update(withSong song: MediaLibraryHelper.Song) {
        self.labelTitle.text = song.title
        self.updateDetailLabel(withSong: song)
        DispatchQueue.global(qos: .default).async {
            let image = song.artwork?.image(at: CGSize(width: 80.0, height: 80.0))
            DispatchQueue.main.async {
                self.imageAlbum.image = image ?? #imageLiteral(resourceName: "placeholder-artwork")
            }
        }
    }
    
    private func updateDetailLabel(withSong song: MediaLibraryHelper.Song) {
        var details = "\(song.albumTrackNumber)."
        if let artistName = song.artist {
            details += " \(artistName)"
        }
        if let albumName = song.albumTitle, !albumName.isEmpty {
            details += " - \(albumName)"
        }
        self.labelDetails.text = details
        self.labelDetails.isHidden = false
    }
    
    func update(withAlbum album: MediaLibraryHelper.Album) {
        self.labelTitle.text = album.representativeItem?.albumTitle ?? "Unknown Album"
        self.updateDetailLabel(withAlbum: album)
        DispatchQueue.global(qos: .default).async {
            let image = album.representativeItem?.artwork?.image(at: CGSize(width: 80.0, height: 80.0))
            DispatchQueue.main.async {
                self.imageAlbum.image = image ?? #imageLiteral(resourceName: "placeholder-artwork")
            }
        }
    }
    
    private func updateDetailLabel(withAlbum album: MediaLibraryHelper.Album) {
        self.labelDetails.text = "\(album.count) songs"
        self.labelDetails.isHidden = false
    }
    
    // MARK: - SelfSizing
    static func sizeConstrained(toWidth width: CGFloat, withData: Any?) -> CGSize {
        return CGSize(width: width, height: 70.0)
    }
    
}
