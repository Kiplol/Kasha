//
//  ArtistViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/10/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import AsyncDisplayKit
import MediaPlayer
import UIKit

class AlbumsViewController: KashaViewController, ASCollectionDataSource {

    // MARK: - ivars
    private let artist: MPMediaItemCollection?
    private let albums: [MPMediaItemCollection]!
    private let collectionNode = ASCollectionNode(layoutDelegate: ASCollectionFlowLayoutDelegate(),
                                                                        layoutFacilitator: nil)
    
    // MARK: - Initializers
    init(artist: MPMediaItemCollection? = nil) {
        self.artist = artist
        if let artist = artist {
            self.albums = MediaLibraryHelper.shared.albums(forArtist: artist)
        } else {
            self.albums = MediaLibraryHelper.shared.allAlbums()
        }
        
        super.init(node: self.collectionNode)
        if let artist = artist {
            self.title = artist.representativeItem?.artist
        } else {
            self.title = "Albums"
        }
        
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumInteritemSpacing = 0.0
//        layout.minimumLineSpacing = 0.0
//        layout.sectionInset = UIEdgeInsets.zero
//        self.collectionNode.collectionViewLayout = layout
        self.collectionNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - ASCollectionDataSource
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let album = self.albums[indexPath.row]
        
        let cellNodeBlock = { () -> ASCellNode in
            let albumNode = AlbumCollectionNode(album: album)
            albumNode.maxWidth = collectionNode.calculatedSize.width * 0.5
            return albumNode
        }
        
        return cellNodeBlock
    }
}
