//
//  FirstViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/4/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import AsyncDisplayKit
import MediaPlayer
import UIKit

class ArtistsViewController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {

    // MARK: - ivars
    fileprivate let tableNode = ASTableNode()
    fileprivate let allArtistsQuery = MPMediaQuery.artists()
    
    // MARK: - Initializers
    init() {
        super.init(node: self.tableNode)

        tableNode.delegate = self
        tableNode.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helpers
    func artist(forRowAt indexPath: IndexPath) -> MPMediaItemCollection {
        guard let artist = self.allArtistsQuery.collections?[indexPath.row] else {
            preconditionFailure("No artist for row at indexPath \(indexPath)")
        }
        return artist
    }

    // MARK: - ASTableDataSource
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let artist = self.artist(forRowAt: indexPath)
        let artistNode = ASTextCellNode()
        artistNode.text = artist.representativeItem?.artist ?? "Unknown Arist"
        return artistNode
    }
    
    // MARK: - ASTableDelegate
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.allArtistsQuery.collections?.count ?? 0
    }

}
