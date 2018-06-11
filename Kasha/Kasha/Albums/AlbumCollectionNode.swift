//
//  AlbumCollectionNode.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/10/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import AsyncDisplayKit
import MediaPlayer
import UIKit

class AlbumCollectionNode: ASCellNode {
    
    private static let imageWidth: CGFloat = 120.0
    private static let overallInset: CGFloat = 6.0
    
    let labelAlbumName = ASTextNode()
    let image = ASImageNode()
    var maxWidth: CGFloat?
    
    init(album: MPMediaItemCollection) {
        super.init()
        self.automaticallyManagesSubnodes = true
        
        self.labelAlbumName.attributedText = NSAttributedString(string:
            album.representativeItem?.albumTitle ?? "Unknown Album")
        self.labelAlbumName.maximumNumberOfLines = 1
        self.labelAlbumName.truncationMode = .byTruncatingTail
        self.labelAlbumName.style.flexShrink = 1.0
        
        let imageSize = CGSize(width: AlbumCollectionNode.imageWidth, height: AlbumCollectionNode.imageWidth)
        self.image.image = (album.representativeItem?.artwork)?.image(at: imageSize)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageRatioSpec = ASRatioLayoutSpec(ratio: 1.0, child: self.image)
        let rootVerticalStack = ASStackLayoutSpec(direction: .vertical, spacing: 8.0,
                                                  justifyContent: .start, alignItems: .center,
                                                  children: [imageRatioSpec, self.labelAlbumName])
        
        
        let insetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: AlbumCollectionNode.overallInset,
                                                               left: AlbumCollectionNode.overallInset,
                                                               bottom: AlbumCollectionNode.overallInset,
                                                               right: AlbumCollectionNode.overallInset),
                                          child: rootVerticalStack)
        if let maxWidth = self.maxWidth {
            let wrapperSpec = ASWrapperLayoutSpec(layoutElement: insetSpec)
            wrapperSpec.style.width = ASDimension(unit: .points, value: floor(maxWidth))
            return wrapperSpec
        }
        return insetSpec
    }

}
