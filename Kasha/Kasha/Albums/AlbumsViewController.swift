//
//  AlbumsViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import BDKCollectionIndexView
import MediaPlayer
import SwiftIcons
import UIKit
import ViewAnimator

class AlbumsViewController: KashaViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private static let albumCellID = "albumCellID"
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indexView: BDKCollectionIndexView!
    
    // MARK: - ivars
    private let albumSections = MediaLibraryHelper.shared.allAlbumSections()
    private var sections: [Section] = []

    // MARK: - KashaViewController
    override func commonInit() {
        super.commonInit()
        self.title = "Albums"
        self.tabBarItem.image = #imageLiteral(resourceName: "albums")
    }
    
    override func doFirstLayoutAnimation() {
        let animations = [AnimationType.zoom(scale: 0.9)]
        self.collectionView.reloadData()
        self.collectionView.performBatchUpdates({
            UIView.animate(views: self.collectionView.visibleCells, animations: animations, reversed: false, initialAlpha: 0.6, finalAlpha: 1.0, delay: 0.0, animationInterval: 0.0, duration: 0.2)
            UIView.animate(views: self.collectionView.visibleCells, animations: animations, completion: {
            })
        })
    }
    
    override func allowsSearch() -> Bool {
        return true
    }
    
    override func scrollViewToInsetForMiniPlayer() -> UIScrollView? {
        return self.collectionView
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.traitCollection.forceTouchCapability == .available {
            self.registerForPreviewing(with: self, sourceView: self.collectionView)
        }
        
        self.populateSections()
        
        //Collection View
        let albumCellNib = UINib(nibName: "AlbumCollectionViewCell", bundle: Bundle.main)
        self.collectionView.register(albumCellNib, forCellWithReuseIdentifier: AlbumsViewController.albumCellID)
        
        //Section Index
        self.indexView.addTarget(self, action: #selector(AlbumsViewController.indexViewValueChanged(sender:)),
                                 for: .valueChanged)
        self.indexView.indexTitles = self.albumSections.map { $0.title }
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let albumVC = segue.destination as? AlbumViewController {
            if let album = sender as? MediaLibraryHelper.Album {
                albumVC.album = album
            }
        }
    }
    
    // MARK: - Helpers
    private func populateSections() {
        self.sections.removeAll()
        
        let albumSections = MediaLibraryHelper.shared.allAlbumSections().map {
            Section(title: $0.title, rows: MediaLibraryHelper.shared.allAlbums(inSection: $0).map {
                Row(data: $0, cellReuseIdentifier: AlbumsViewController.albumCellID)
            })
        }
        if !albumSections.isEmpty {
            self.sections.append(contentsOf: albumSections)
        }
    }
    
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
        let album = self.album(forIndexPath: indexPath)
        self.performSegue(withIdentifier: "albumsToAlbum", sender: album)
    }
}

extension AlbumsViewController {
    // MARK: - Index View
    @objc func indexViewValueChanged(sender: BDKCollectionIndexView) {
        let path = IndexPath(item: 0, section: Int(sender.currentIndex))
        self.collectionView.scrollToItem(at: path, at: .top, animated: false)
    }
}

extension AlbumsViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else {
            return nil
        }
        
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let album = row.data as? MediaLibraryHelper.Album {
            let albumVC = AlbumViewController.with(album: album)
            return albumVC
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
    }
    
}
