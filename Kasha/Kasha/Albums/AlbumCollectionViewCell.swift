//
//  AlbumCollectionViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Hue
import MediaPlayer
import UIKit

class AlbumCollectionViewCell: UICollectionViewCell, SelfSizing {
    
    static let idealWidth: CGFloat = 170.0
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageAlbum: UIImageView!
    @IBOutlet weak var everythingContainer: UIView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var labelAlbumName: UILabel!
    @IBOutlet weak var labelArtistName: UILabel!
    @IBOutlet weak var gradientView: UIView!
    private let gradient = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
//        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.imageAlbum.applyAlbumStyleRoundedCorners()
        self.imageContainer.applyAlbumStyleRoundedCorners()
        self.everythingContainer.applyAlbumsStyle()
        
        self.gradient.colors = [UIColor.black.alpha(0.0).cgColor, UIColor.black.alpha(0.7).cgColor,
                                UIColor.black.alpha(0.8).cgColor]
        self.gradient.locations = [0.0, 0.40, 1.0]
        self.gradientView.layer.addSublayer(self.gradient)
    }
    
    func update(withAlbum album: MPMediaItemCollection) {
        self.labelAlbumName.text = album.representativeItem?.albumTitle ?? "Unknown Album"
        self.labelArtistName.text = album.representativeItem?.artist ?? "Unknown Artist"
        DispatchQueue.global(qos: .default).async {
            let image = album.representativeItem?.artwork?.image(at: CGSize(width: 200.0, height: 200.0))
            DispatchQueue.main.async {
                self.imageAlbum.image = image
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.gradient.frame = self.gradientView.bounds
    }
    
    // MARK: - SelfSizing
    static func sizeConstrained(toWidth width: CGFloat, withData: Any?) -> CGSize {
        return CGSize(width: width, height: width)
    }
}
