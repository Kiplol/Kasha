//
//  SearchResultsViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/24/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class SearchResultsViewController: KashaViewController, UISearchResultsUpdating {
    
    private static let songCellID = "songCellID"
    private static let artistCellID = "artistCellID"
    
    // MARK: - ivars
    let tableView = UITableView(frame: .zero, style: .plain)
    var songs: [MediaLibraryHelper.Song] = []
    var albums: [MediaLibraryHelper.Album] = []
    var artists: [MediaLibraryHelper.Artist] = []
    private var sections: [Section] = []
    
    // MARK: - KashaViewController
    override func allowsSearch() -> Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.tableView.frame = self.view.bounds
        self.view.addSubview(self.tableView)
        
        let songCellNib = UINib(nibName: "SongTableViewCell", bundle: Bundle.main)
        self.tableView.register(songCellNib, forCellReuseIdentifier: SearchResultsViewController.songCellID)
        
        let artistCellNib = UINib(nibName: "ArtistTableViewCell", bundle: Bundle.main)
        self.tableView.register(artistCellNib, forCellReuseIdentifier: SearchResultsViewController.artistCellID)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    // MARK: - Helpers
    private func populateSections() {
        self.sections.removeAll()
        
        if !self.artists.isEmpty {
            let artistsSection = Section(title: "Artists", rows: self.artists.map {
                Row(data: $0, cellReuseIdentifier: SearchResultsViewController.artistCellID)
            })
            self.sections.append(artistsSection)
        }
        
        if !self.songs.isEmpty {
            let songsSection = Section(title: "Songs", rows: self.songs.map {
                Row(data: $0, cellReuseIdentifier: SearchResultsViewController.songCellID)
            })
            self.sections.append(songsSection)
        }
        
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            self.viewIfLoaded?.isHidden = true
            return
        }
        MediaLibraryHelper.shared.searh(for: query) { songs, albums, artists in
            self.songs = songs
            self.albums = albums
            self.artists = artists
            self.populateSections()
            self.viewIfLoaded?.isHidden = self.sections.isEmpty
        }
    }

}

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseIdentifier, for: indexPath)
        
        if let songCell = cell as? SongTableViewCell, let song = row.data as? MediaLibraryHelper.Song {
            songCell.update(withSong: song)
        } else if let artistCell = cell as? ArtistTableViewCell, let artist = row.data as? MediaLibraryHelper.Artist {
            artistCell.update(withArtist: artist)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
        
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        switch row.data {
        case is MediaLibraryHelper.Song:
            return SongTableViewCell.sizeConstrained(toWidth: tableView.bounds.size.width, withData: row.data).height
        default:
            return 70.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let song = row.data as? MediaLibraryHelper.Song {
            MediaLibraryHelper.shared.play(song)
        } else if let artist = row.data as? MediaLibraryHelper.Artist,
            row.cellReuseIdentifier == SearchResultsViewController.artistCellID {
            //@TODO: Show artist VC
        }
    }
}
