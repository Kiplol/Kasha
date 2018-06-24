//
//  AlbumViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/24/18.
//  Copyright © 2018 Kip. All rights reserved.
//

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

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Table View
        let songCellNib = UINib(nibName: "SongTableViewCell", bundle: Bundle.main)
        self.tableView.register(songCellNib, forCellReuseIdentifier: AlbumViewController.songCellID)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let song = row.data as? MediaLibraryHelper.Song {
            return SongTableViewCell.sizeConstrained(toWidth: tableView.bounds.size.width, withData: song).height
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let song = row.data as? MediaLibraryHelper.Song {
            MediaLibraryHelper.shared.play(song, inQueue: self.songs)
        }
    }

}
