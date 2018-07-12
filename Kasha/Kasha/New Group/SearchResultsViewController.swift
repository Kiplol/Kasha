//
//  SearchResultsViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/24/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

protocol SearchResultsViewControllerDelegate: class {
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didSelectAlbum album: MediaLibraryHelper.Album)
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didSelectArtist artist: MediaLibraryHelper.Artist)
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didSelectPlaylist playlist: MediaLibraryHelper.Playlist)
}

class SearchResultsViewController: KashaViewController, UISearchResultsUpdating {
    
    private static let songCellID = "songCellID"
    private static let artistCellID = "artistCellID"
    private static let albumCellID = "albumCellID"
    private static let playlistCellID = "playlistCellID"
    private static let maxResultPerSection = 6
    
    // MARK: - ivars
    let tableView = UITableView(frame: .zero, style: .plain)
    var songs: [MediaLibraryHelper.Song] = []
    var albums: [MediaLibraryHelper.Album] = []
    var artists: [MediaLibraryHelper.Artist] = []
    var playlists: [MediaLibraryHelper.Playlist] = []
    private var sections: [Section] = []
    weak var delegate: SearchResultsViewControllerDelegate?
    
    // MARK: - KashaViewController
    override func allowsSearch() -> Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.tableView.frame = self.view.bounds
        self.tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        
        let songCellNib = UINib(nibName: "KashaTableViewCell", bundle: Bundle.main)
        self.tableView.register(songCellNib, forCellReuseIdentifier: SearchResultsViewController.songCellID)
        self.tableView.register(songCellNib, forCellReuseIdentifier: SearchResultsViewController.albumCellID)
        self.tableView.register(songCellNib, forCellReuseIdentifier: SearchResultsViewController.playlistCellID)
        
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
        
        if !self.albums.isEmpty {
            let albumsSection = Section(title: "Albums", rows: self.albums.map {
                Row(data: $0, cellReuseIdentifier: SearchResultsViewController.albumCellID)
            })
            self.sections.append(albumsSection)
        }
        
        if !self.songs.isEmpty {
            let songsSection = Section(title: "Songs", rows: self.songs.map {
                Row(data: $0, cellReuseIdentifier: SearchResultsViewController.songCellID)
            })
            self.sections.append(songsSection)
        }
        
        if !self.playlists.isEmpty {
            let playlistsSection = Section(title: "Playlists", rows: self.playlists.map {
                Row(data: $0, cellReuseIdentifier: SearchResultsViewController.playlistCellID)
            })
            self.sections.append(playlistsSection)
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
        MediaLibraryHelper.shared.searh(for: query) { songs, albums, artists, playlists in
            self.songs = songs
            self.albums = albums
            self.artists = artists
            self.playlists = playlists
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
        //@TODO: return min(self.sections[section].rows.count, SearchResultsViewController.maxResultPerSection)
        return self.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseIdentifier, for: indexPath)
        
        switch row.cellReuseIdentifier {
        case SearchResultsViewController.songCellID:
            if let songCell = cell as? KashaTableViewCell, let song = row.data as? MediaLibraryHelper.Song {
                songCell.update(withSong: song)
                songCell.selectionDisplayStyle = .nowPlaying
            }
        case SearchResultsViewController.artistCellID:
            if let artistCell = cell as? ArtistTableViewCell, let artist = row.data as? MediaLibraryHelper.Artist {
                artistCell.update(withArtist: artist)
            }
        case SearchResultsViewController.albumCellID:
            if let albumCell = cell as? KashaTableViewCell, let album = row.data as? MediaLibraryHelper.Album {
                albumCell.update(withAlbum: album)
                albumCell.selectionDisplayStyle = .default
            }
        case SearchResultsViewController.playlistCellID:
            if let playlistCell = cell as? KashaTableViewCell, let playlist = row.data as? MediaLibraryHelper.Playlist {
                playlistCell.update(withPlaylist: playlist)
                playlistCell.selectionDisplayStyle = .default
            }
        default:
            break
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
            return KashaTableViewCell.sizeConstrained(toWidth: tableView.bounds.size.width, withData: row.data).height
        default:
            return 70.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        
        switch row.cellReuseIdentifier {
        case SearchResultsViewController.songCellID:
            if let song = row.data as? MediaLibraryHelper.Song {
                MediaLibraryHelper.shared.play(song)
            }
        case SearchResultsViewController.artistCellID:
            if let artist = row.data as? MediaLibraryHelper.Artist {
                self.delegate?.searchResultsViewController(self, didSelectArtist: artist)
            }
        case SearchResultsViewController.albumCellID:
            if let album = row.data as? MediaLibraryHelper.Album {
               self.delegate?.searchResultsViewController(self, didSelectAlbum: album)
            }
        case SearchResultsViewController.playlistCellID:
            if let playlist = row.data as? MediaLibraryHelper.Playlist {
                self.delegate?.searchResultsViewController(self, didSelectPlaylist: playlist)
            }
        default:
            break
        }
    }
}
