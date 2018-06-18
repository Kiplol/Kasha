//
//  AlbumsViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class AlbumsViewController: KashaViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private static let albumCellID = "albumCellID"
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - ivars
    private let albumSections = MediaLibraryHelper.shared.allAlbumSections()

    // MARK: - KashaViewController
    override func commonInit() {
        super.commonInit()
        self.title = "Albums"
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let albumCellNib = UINib(nibName: "AlbumCollectionViewCell", bundle: Bundle.main)
        self.collectionView.register(albumCellNib, forCellWithReuseIdentifier: AlbumsViewController.albumCellID)
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
    
    // MARK: - Helpers
    private func album(forIndexPath indexPath: IndexPath) -> MPMediaItemCollection {
        let section = self.albumSections[indexPath.section]
        return MediaLibraryHelper.shared.album(forSection: section, atIndex: indexPath.row)
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.albumSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albumSections[section].range.length
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumsViewController.albumCellID,
                                                      for: indexPath)
        if let albumCell = cell as? AlbumCollectionViewCell {
            albumCell.update(withAlbum: self.album(forIndexPath: indexPath))
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let songsVC = SongsViewController.fromStoryboard()
        let album = self.album(forIndexPath: indexPath)
        songsVC.songs = MediaLibraryHelper.shared.allSongs(fromAlbum: album)
        songsVC.title = album.representativeItem?.albumTitle
        self.show(songsVC, sender: album)
    }
}
