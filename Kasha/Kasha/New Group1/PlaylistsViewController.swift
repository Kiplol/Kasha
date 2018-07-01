//
//  PlaylistsViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/29/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit
import ViewAnimator

class PlaylistsViewController: KashaViewController, UITableViewDataSource, UITableViewDelegate {
    
    private static let playlistCellID = "playlistCellID"
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ivars
    private var sections: [Section] = []
    var parentPlaylistFolder: MediaLibraryHelper.PlaylistFolder?
    
    // MARK: -
    class func with(parentPlaylistFolder: MediaLibraryHelper.PlaylistFolder) -> PlaylistsViewController {
        guard let playlistsVC = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "playlists") as? PlaylistsViewController else {
                preconditionFailure("Couldn't instantiate a PlaylistsViewController from storyboard")
        }
        playlistsVC.parentPlaylistFolder = parentPlaylistFolder
        return playlistsVC
    }
    
    // MARK: - KashaViewController
    override func commonInit() {
        super.commonInit()
        self.title = "Playlists"
        self.tabBarItem.image = UIImage.init(icon: .googleMaterialDesign(.list),
                                             size: CGSize(width: 50.0, height: 50.0))
    }
    
    override func doFirstLayoutAnimation() {
        super.doFirstLayoutAnimation()
        let animations = [AnimationType.from(direction: .bottom, offset: 30.0)]
        self.tableView.reloadData()
        UIView.animate(views: self.tableView.visibleCells, animations: animations, completion: nil)
    }
    
    override func allowsSearch() -> Bool {
        return true
    }
    
    override func scrollViewToInsetForMiniPlayer() -> UIScrollView? {
        return self.tableView
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table View
        let playlistCellNib = UINib(nibName: "PlaylistTableViewCell", bundle: Bundle.main)
        self.tableView.register(playlistCellNib, forCellReuseIdentifier: PlaylistsViewController.playlistCellID)
        
        // Parent Playlist Folder
        if let folder = self.parentPlaylistFolder {
            self.title = folder.name
        }
        
        self.populateSections()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let albumVC = segue.destination as? AlbumViewController,
            let playlist = sender as? MediaLibraryHelper.Playlist {
            albumVC.songs = playlist.items
            albumVC.title = playlist.name
        }
    }
    
    // MARK: - Helpers
    private func populateSections() {
        self.sections.removeAll()
        
        if let folder = self.parentPlaylistFolder {
            let playlistsSection = Section(title: nil, rows: MediaLibraryHelper.shared
                .allPlaylists(inPlaylistFolder: folder)?.map {
                    Row(data: $0, cellReuseIdentifier: PlaylistsViewController.playlistCellID)
            })
            self.sections.append(playlistsSection)
        } else {
            let foldersSection = Section(title: nil, rows: MediaLibraryHelper.shared.allPlaylistFolders().map {
                Row(data: $0, cellReuseIdentifier: PlaylistsViewController.playlistCellID)
            })
            self.sections.append(foldersSection)
            
            let playlistsSection = Section(title: nil, rows: MediaLibraryHelper.shared.allPlaylistsNotInFolders().map {
                Row(data: $0, cellReuseIdentifier: PlaylistsViewController.playlistCellID)
            })
            self.sections.append(playlistsSection)
        }
        
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
        let row = self.sections[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseIdentifier, for: indexPath)
        if let playlistCell = cell as? PlaylistTableViewCell, let playlist = row.data as? MediaLibraryHelper.Playlist {
            playlistCell.update(withPlaylist: playlist)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlaylistTableViewCell.sizeConstrained(toWidth: tableView.bounds.size.width,
                                                     withData: self.sections[indexPath.section].rows[indexPath.row].data).height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let playlist = row.data as? MediaLibraryHelper.Playlist, !playlist.isFolder {
            self.performSegue(withIdentifier: "playlistsToAlbum", sender: playlist)
        } else if let playlistFolder = row.data as? MediaLibraryHelper.PlaylistFolder {
            let playlistsVC = PlaylistsViewController.with(parentPlaylistFolder: playlistFolder)
            playlistsVC.parentPlaylistFolder = playlistFolder
            self.show(playlistsVC, sender: self)
        }
    }
    
}
