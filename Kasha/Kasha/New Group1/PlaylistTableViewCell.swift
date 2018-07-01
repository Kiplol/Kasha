//
//  PlaylistTableViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/29/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class PlaylistTableViewCell: UITableViewCell, SelfSizing {
    
    // MARK: - IBOutlets
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetails: UILabel!
    @IBOutlet weak var imageCover: ImageContainerView!
    
    func update(withPlaylist playlist: MediaLibraryHelper.Playlist) {
        self.labelTitle.text = playlist.name
        if playlist.isFolder {
            self.labelDetails.isHidden = true
        } else {
            self.labelDetails.text = "\(playlist.count) songs"
            self.labelDetails.isHidden = false
        }
        DispatchQueue.global(qos: .default).async {
            let image = playlist.representativeItem?.artwork?.image(at: CGSize(width: 54.0, height: 54.0))
            DispatchQueue.main.async {
                self.imageCover.image = image ?? #imageLiteral(resourceName: "placeholder-artwork")
            }
        }
    }
    
    // MARK: - SelfSizing
    static func sizeConstrained(toWidth width: CGFloat, withData: Any?) -> CGSize {
        return CGSize(width: width, height: 100)
    }
    
}
