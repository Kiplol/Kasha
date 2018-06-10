//
//  ArtistTableNode.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/7/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import AsyncDisplayKit
import MediaPlayer
import UIKit

class ArtistTableNode: ASCellNode {
    
    private static let imageWidth: CGFloat = 70.0
    
    let artist: MPMediaItemCollection
    let labelArtistName = ASTextNode()
    let image = ASImageNode()
    
    init(artist: MPMediaItemCollection) {
        self.artist = artist
        super.init()
        
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18.0)]
        self.labelArtistName.attributedText = NSAttributedString(string: artist.representativeItem?.artist ??
            "Unknown Artist", attributes: attributes)
        self.labelArtistName.maximumNumberOfLines = 1
        self.labelArtistName.truncationMode = .byTruncatingTail
        self.labelArtistName.style.flexShrink = 1.0
        self.labelArtistName.truncationAttributedText = NSAttributedString(string: "...")
        self.image.image = (artist.representativeItem?.artwork)?.image(at: CGSize(width: 100.0, height: 100.0))
        DispatchQueue.main.async {
            self.image.layer.cornerRadius = 4.0
        }
        
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let padding: CGFloat = 12.0
        
        //Image
        self.image.style.preferredSize = CGSize(width: ArtistTableNode.imageWidth, height: ArtistTableNode.imageWidth)
        
        //Stack
        let stack = ASStackLayoutSpec.horizontal()
        stack.alignItems = .center
        stack.spacing = padding
        stack.children = [self.image, self.labelArtistName]

        //Inset
        let inset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: padding,
                                                           left: padding,
                                                           bottom: padding,
                                                           right: padding),
                                      child: stack)

        return inset
    }
    
}
