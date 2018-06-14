//
//  ArtistsViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class ArtistsViewController: KashaViewController, UITableViewDataSource, UITableViewDelegate {
    
    private static let cellID = "artistCellID"

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ivars
    private let artistSections = MediaLibraryHelper.shared.allArtistSections()
    
    // MARK: - KashaViewController
    override func commonInit() {
        super.commonInit()
        self.title = "Artists"
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let artistCellNib = UINib(nibName: "ArtistTableViewCell", bundle: Bundle.main)
        self.tableView.register(artistCellNib, forCellReuseIdentifier: ArtistsViewController.cellID)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedRow, animated: animated)
        }
    }
    
    // MARK: - Helpers
    private func artist(forIndexPath indexPath: IndexPath) -> MPMediaItemCollection {
        let section = self.artistSections[indexPath.section]
        return MediaLibraryHelper.shared.artist(forSection: section, atIndex: indexPath.row)
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.artistSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artistSections[section].range.length
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArtistsViewController.cellID, for: indexPath)
        if let artistCell = cell as? ArtistTableViewCell {
            artistCell.update(withArtist: self.artist(forIndexPath: indexPath))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ArtistTableViewCell.cellHeight
    }
    
    // MARK: Section Indeces
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.artistSections.compactMap { $0.title }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionIndexTitles(for: tableView)?[section]
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}