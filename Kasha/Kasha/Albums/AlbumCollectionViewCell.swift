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

class AlbumCollectionViewCell: UICollectionViewCell {
    
    static let idealWidth: CGFloat = 170.0
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageAlbum: ImageContainerView!
    @IBOutlet weak var constraintWidth: NSLayoutConstraint!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var textBackground: UIView!
    @IBOutlet weak var labelAlbumName: UILabel!
    
    // MARK: - ivars
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
        self.imageAlbum.applyAlbumsStyle()
    }
    
    func update(withAlbum album: MPMediaItemCollection) {
        self.labelAlbumName.text = album.representativeItem?.albumTitle ?? "Unknown Album"
        DispatchQueue.global(qos: .default).async {
            let image = album.representativeItem?.artwork?.image(at: CGSize(width: 200.0, height: 200.0))
            let (bgColor, textColor): (UIColor, UIColor) = {
                if let (bg, primary, _, _) = image?.colors() {
                    return (bg, primary)
                } else {
                    return (UIColor.black, UIColor.white)
                }
            }()
            
            DispatchQueue.main.async {
                self.labelAlbumName.textColor = textColor
                self.textBackground.backgroundColor = bgColor
                self.imageAlbum.image = image
            }
        }
    }

}
