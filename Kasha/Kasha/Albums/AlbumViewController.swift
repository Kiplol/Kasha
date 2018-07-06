//
//  AlbumViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/24/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class AlbumViewController: KashaViewController, UITableViewDataSource, UITableViewDelegate {
    
    private static let songCellID = "songCellID"
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ivars
    var songs: [MediaLibraryHelper.Song] = [] {
        didSet {
            self.populateSections()
        }
    }
    var album: MediaLibraryHelper.Album? {
        didSet {
            if let album = self.album {
                self.title = album.representativeItem?.albumTitle
                self.songs = MediaLibraryHelper.shared.allSongs(fromAlbum: album)
            }
        }
    }
    private var sections: [Section] = []
    
    // MARK: - KashaViewController
    override func scrollViewToInsetForMiniPlayer() -> UIScrollView? {
        return self.tableView
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table View
        let songCellNib = UINib(nibName: "SongTableViewCell", bundle: Bundle.main)
        self.tableView.register(songCellNib, forCellReuseIdentifier: AlbumViewController.songCellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(AlbumViewController.nowPlayingItemDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    // MARK: - Helpers
    private func populateSections() {
        self.sections.removeAll()
        self.sections.append(Section(title: nil, rows: self.songs.map {
            Row(data: $0, cellReuseIdentifier: AlbumViewController.songCellID)
        }))
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - MediaNotifications
    @objc func nowPlayingItemDidChange(_ notif: Notification) {
        guard let player = notif.object as? MPMusicPlayerController else {
            return
        }
        self.tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
        if let nowPlayingItem = player.nowPlayingItem {
            let persistentIDs = self.songs.map { $0.persistentID }
            if let indexPathRow = persistentIDs.index(of: nowPlayingItem.persistentID) {
                tableView.selectRow(at: IndexPath(row: indexPathRow, section: 0), animated: true, scrollPosition: .none)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumViewController.songCellID, for: indexPath)
        let row = self.sections[indexPath.section].rows[indexPath.row]
        
        if let songCell = cell as? SongTableViewCell,
            let song = row.data as? MediaLibraryHelper.Song {
            songCell.update(withSong: song)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let songCell = cell as? SongTableViewCell,
            let song = row.data as? MediaLibraryHelper.Song {
            songCell.setSelected(MediaLibraryHelper.shared.musicPlayer.nowPlayingItem?.persistentID == song.persistentID, animated: true)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let song = row.data as? MediaLibraryHelper.Song {
            return SongTableViewCell.sizeConstrained(toWidth: tableView.bounds.size.width, withData: song).height
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let oldIndexPaths = self.tableView.indexPathsForSelectedRows {
//            oldIndexPaths.filter { $0 != indexPath }.forEach {
//                tableView.deselectRow(at: $0, animated: true)
//            }
//        }
        
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let song = row.data as? MediaLibraryHelper.Song {
            MediaLibraryHelper.shared.play(song, inQueue: self.songs)
        }
    }
    
    private func bar() {
        
    }

}
