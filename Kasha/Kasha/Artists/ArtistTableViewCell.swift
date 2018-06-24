//
//  ArtistTableViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class ArtistTableViewCell: UITableViewCell {
    
    static let cellHeight: CGFloat = 70.0

    // MARK: - IBOutlets
    @IBOutlet weak var imageArtist: ImageContainerView!
    @IBOutlet weak var labelArtistName: UILabel!
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        self.imageArtist.applyAlbumsStyle()
//    }
    
    func update(withArtist artist: MPMediaItemCollection) {
        self.labelArtistName.text = artist.representativeItem?.artist ?? "Unknown Artist"
        DispatchQueue.global(qos: .default).async {
            let image = artist.representativeItem?.artwork?.image(at: CGSize(width: 54.0, height: 54.0))
            DispatchQueue.main.async {
                self.imageArtist.image = image
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
