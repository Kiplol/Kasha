//
//  AlbumCollectionViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    static let idealWidth: CGFloat = 170.0
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageAlbum: UIImageView!
    @IBOutlet weak var constraintWidth: NSLayoutConstraint!
    var width: CGFloat? = nil {
        didSet {
            if let newValue = self.width {
                self.constraintWidth.constant = newValue
                self.setNeedsLayout()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.imageAlbum.applyAlbumStyleRoundedCorners()
        self.imageContainer.applyAlbumsStyle()
    }
    
    func update(withAlbum album: MPMediaItemCollection) {
        DispatchQueue.global(qos: .default).async {
            let image = album.representativeItem?.artwork?.image(at: CGSize(width: 200.0, height: 200.0))
            DispatchQueue.main.async {
                self.imageAlbum.image = image
            }
        }
    }

}
