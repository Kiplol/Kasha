//
//  SongTableViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/24/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell, SelfSizing {

    // MARK: - IBOutlets
    @IBOutlet weak var imageAlbum: ImageContainerView!
    @IBOutlet weak var labelSongName: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    
    func update(withSong song: MediaLibraryHelper.Song) {
        self.labelSongName.text = song.title
        self.updateDetailLabel(withSong: song)
        DispatchQueue.global(qos: .default).async {
            let image = song.artwork?.image(at: CGSize(width: 80.0, height: 80.0))
            DispatchQueue.main.async {
                self.imageAlbum.image = image ?? #imageLiteral(resourceName: "placeholder-artwork")
            }
        }
    }
    
    private func updateDetailLabel(withSong song: MediaLibraryHelper.Song) {
        var details = "Track \(song.albumTrackNumber)"
        if let albumName = song.albumTitle {
            details += " on \(albumName)"
        }
        if let artistName = song.artist {
            details += " by \(artistName)"
        }
        self.labelDetails.text = details
    }
    
    // MARK: - SelfSizing
    static func sizeConstrained(toWidth width: CGFloat, withData: Any?) -> CGSize {
        return CGSize(width: width, height: 70.0)
    }
    
}
