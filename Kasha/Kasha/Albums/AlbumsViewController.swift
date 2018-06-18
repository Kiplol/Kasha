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
        if let flowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 180.0, height: 180.0)
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
            let numberOfColumns = max(floor((collectionView.usableWidth() / AlbumCollectionViewCell.idealWidth)), 2.0)
            albumCell.update(withAlbum: self.album(forIndexPath: indexPath))
            let interItemSpace = collectionView.flowLayout?.minimumInteritemSpacing ?? 0.0
            albumCell.width = floor(collectionView.usableWidth() * (1.0 / numberOfColumns)) - (interItemSpace / numberOfColumns)
        }
        return cell
    }
}
