//
//  ArtistTableViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Gestalt
import MediaPlayer
import UIKit

class ArtistTableViewCell: UITableViewCell, SelfSizing {

    // MARK: - IBOutlets
    @IBOutlet weak var imageArtist: ImageContainerView!
    @IBOutlet weak var labelArtistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.labelArtistName.textColor = theme.textColor
        }
    }
    
    func update(withArtist artist: MPMediaItemCollection) {
        self.labelArtistName.text = artist.representativeItem?.artist ?? "Unknown Artist"
        DispatchQueue.global(qos: .default).async {
            let image = artist.representativeItem?.artwork?.image(at: CGSize(width: 54.0, height: 54.0))
            DispatchQueue.main.async {
                self.imageArtist.image = image ?? #imageLiteral(resourceName: "placeholder-artwork")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - SelfSizing
    static func sizeConstrained(toWidth width: CGFloat, withData: Any?) -> CGSize {
        return CGSize(width: width, height: 70.0)
    }
    
}
