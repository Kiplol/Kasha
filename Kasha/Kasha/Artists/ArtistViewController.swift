//
//  ArtistViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/18/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class ArtistViewController: KashaViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private static let albumCellID = "albumCellID"
    private static let allSongsCellID = "allSongsCellID"
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - ivars
    var artist: MPMediaItemCollection! {
        didSet {
            self.title = self.artist.representativeItem?.artist
            self.populateSections()
        }
    }
    private var sections: [Section] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //Collection View
        let albumCellNib = UINib(nibName: "AlbumCollectionViewCell", bundle: Bundle.main)
        self.collectionView.register(albumCellNib, forCellWithReuseIdentifier: ArtistViewController.albumCellID)
        self.collectionView.register(albumCellNib, forCellWithReuseIdentifier: ArtistViewController.allSongsCellID)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let flowLayout = self.collectionView.flowLayout {
            let numberOfColumns = max(floor((self.collectionView.usableWidth() / AlbumCollectionViewCell.idealWidth)), 2.0)
            let interItemSpace = self.collectionView.flowLayout?.minimumInteritemSpacing ?? 0.0
            let width = floor(self.collectionView.usableWidth() * (1.0 / numberOfColumns)) - (interItemSpace / numberOfColumns)
            flowLayout.itemSize = AlbumCollectionViewCell.sizeConstrained(toWidth: width, withData: nil)
        }
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
        
        // All Songs
        let allSongsRow = Row(data: MediaLibraryHelper.shared.allSongs(forArtist: self.artist),
                              cellReuseIdentifier: ArtistViewController.allSongsCellID)
        let allSongsSection = Section(title: "All Songs", rows: [allSongsRow])
        self.sections.append(allSongsSection)
        
        // Albums
        let albums = MediaLibraryHelper.shared.albums(forArtist: self.artist)
        if !albums.isEmpty {
            let albumsSection = Section(title: "Albums")
            albumsSection.rows.append(contentsOf: albums.map {
                Row(data: $0, cellReuseIdentifier: ArtistViewController.albumCellID)
            })
            self.sections.append(albumsSection)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.sections[indexPath.section]
        let row = section.rows[indexPath.row]
        let cellID = row.cellReuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        
        if let albumCell = cell as? AlbumCollectionViewCell {
            switch cellID {
            case ArtistViewController.allSongsCellID:
                albumCell.updateAsAllSongs(forArtist: self.artist)
            case ArtistViewController.albumCellID:
                if let album = row.data as? MediaLibraryHelper.Album {
                    albumCell.update(withAlbum: album)
                }
            default:
                break
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate

}
