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

class ArtistsViewController: KashaViewController, ASTableDataSource, ASTableDelegate, UITableViewDelegate {

    // MARK: - ivars
    fileprivate let tableNode = ASTableNode()
    fileprivate let allArtistsQuery = MPMediaQuery.artists()
    
    // MARK: - Initializers
    init() {
        super.init(node: self.tableNode)
        self.title = "Artists"
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
        guard let section = self.artists(forSection: indexPath.section) else {
            preconditionFailure("No artist section for row at indexPath \(indexPath)")
        }
        let currentLocation = section.range.location + indexPath.row
        guard let artist = self.allArtistsQuery.collections?[currentLocation] else {
            preconditionFailure("No artist for row at indexPath \(indexPath)")
        }
        return artist
    }
    
    func artists(forSection section: Int) -> MPMediaQuerySection? {
        return self.allArtistsQuery.collectionSections?[section]
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionIndexTitles(for: tableView)?[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U",
//                "V", "W", "X", "Y", "Z", "#"]
        return self.allArtistsQuery.collectionSections?.compactMap { $0.title }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }

    // MARK: - ASTableDataSource
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let artist = self.artist(forRowAt: indexPath)
        
        let cellNodeBlock = { () -> ASCellNode in
            let artistNode = ArtistTableNode(artist: artist)
            return artistNode
        }
        
        return cellNodeBlock
    }
    
    // MARK: - ASTableDelegate
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return self.allArtistsQuery.collectionSections?.count ?? 0
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.artists(forSection: section)?.range.length ?? 0
    }

}
