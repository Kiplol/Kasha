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
    override var previewActionItems: [UIPreviewActionItem] {
        return [
            UIPreviewAction(title: "Play", style: .default, handler: { _, _ in
                if let firstSong = self.songs.first {
                    MediaLibraryHelper.shared.tunOffShuffle()
                    MediaLibraryHelper.shared.play(firstSong, inQueue: self.songs)
                }
            }),
            UIPreviewAction(title: "Shuffle", style: .default, handler: { _, _ in
                guard !self.songs.isEmpty else {
                    return
                }
                let randomIndex = Int(arc4random_uniform(UInt32(self.songs.count)))
                let song = self.songs[randomIndex]
                MediaLibraryHelper.shared.play(song, inQueue: self.songs)
                MediaLibraryHelper.shared.turnOnShuffle()
            })
        ]
    }
    
    // MARK: -
    class func fromStoryboard() -> AlbumViewController {
        guard let albumVC = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "songs") as? AlbumViewController else {
                preconditionFailure("Couldn't instantiate a AlbumViewController from storyboard")
        }
        return albumVC
    }
    class func with(album: MediaLibraryHelper.Album) -> AlbumViewController {
        let albumVC = AlbumViewController.fromStoryboard()
        albumVC.album = album
        return albumVC
    }
    
    class func with(playlist: MediaLibraryHelper.Playlist) -> AlbumViewController {
        let albumVC = AlbumViewController.fromStoryboard()
        albumVC.songs = playlist.items
        albumVC.title = playlist.name
        return albumVC
    }
    
    class func with(songs: [MediaLibraryHelper.Song]) -> AlbumViewController {
        let albumVC = AlbumViewController.fromStoryboard()
        albumVC.songs = songs
        return albumVC
    }
    
    // MARK: - KashaViewController
    override func scrollViewToInsetForMiniPlayer() -> UIScrollView? {
        return self.tableView
    }
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        self.tableView.backgroundColor = theme.backgroundColor
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table View
        let songCellNib = UINib(nibName: "KashaTableViewCell", bundle: Bundle.main)
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
    
    // MARK: - User Interaction
    @objc func accessoryTapped(_ sender: AnyObject?, event: UIEvent?) {
        guard let touch = event?.allTouches?.first,
        let indexPath = self.tableView.indexPathForRow(at: touch.location(in: self.tableView)) else {
            return
        }
        
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let song = row.data as? MediaLibraryHelper.Song {
            self.present(MediaLibraryHelper.shared.actionsAlert(forSong: song,
                                                                withViewController: self),
                         animated: true,
                         completion: nil)
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
        
        if let songCell = cell as? KashaTableViewCell,
            let song = row.data as? MediaLibraryHelper.Song {
            songCell.selectionDisplayStyle = .nowPlaying
            songCell.update(withSong: song)
            let accessoryButton = UIButton(type: .system)
            accessoryButton.setImage(#imageLiteral(resourceName: "more"), for: .normal)
            accessoryButton.addTarget(self, action: #selector(AlbumViewController.accessoryTapped(_:event:)), for: .touchUpInside)
            accessoryButton.sizeToFit()
            songCell.accessoryView = accessoryButton
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let songCell = cell as? KashaTableViewCell,
            let song = row.data as? MediaLibraryHelper.Song {
            songCell.setSelected(MediaLibraryHelper.shared.musicPlayer.nowPlayingItem?.persistentID == song.persistentID, animated: true)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let song = row.data as? MediaLibraryHelper.Song {
            return KashaTableViewCell.sizeConstrained(toWidth: tableView.bounds.size.width, withData: song).height
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
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        print("yay?")
//    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        return [UITableViewRowAction(style: .normal, title: "Test", handler: { (action, indexPath) in
//            print("fart")
//        }), UITableViewRowAction(style: .normal, title: "Poo", handler: { (action, indexPath) in
//            print("fart2")
//        })]
//    }
//
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        let row = self.sections[indexPath.section].rows[indexPath.row]
//        if let song = row.data as? MediaLibraryHelper.Song {
//            self.present(MediaLibraryHelper.shared.actionsAlert(forSong: song,
//                                                                withViewController: self),
//                         animated: true,
//                         completion: nil)
//        }
//    }

}
