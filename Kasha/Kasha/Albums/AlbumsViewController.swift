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
    private let indexView = STBTableViewIndex()

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
        
        self.indexView.autoHides = false
        self.indexView.titles = self.albumSections.map { $0.title }
        self.indexView.delegate = self
        self.view.addSubview(self.indexView)
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
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns = max(floor((collectionView.usableWidth() / AlbumCollectionViewCell.idealWidth)), 2.0)
        let interItemSpace = collectionView.flowLayout?.minimumInteritemSpacing ?? 0.0
        let width = floor(collectionView.usableWidth() * (1.0 / numberOfColumns)) - (interItemSpace / numberOfColumns)
        return AlbumCollectionViewCell.sizeConstrained(toWidth: width, withData: nil)
    }
}

extension AlbumsViewController: STBTableViewIndexDelegate {
    func tableViewIndexChanged(_ index: Int, title: String) {
        let indexPath = IndexPath(row: 0, section: index)
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
    }
    
    func tableViewIndexTopLayoutGuideLength() -> CGFloat {
        return self.view.safeAreaInsets.top + 20
    }
    
    func tableViewIndexBottomLayoutGuideLength() -> CGFloat {
        var bottomHeight: CGFloat = 0.0
        if let tabBarController = self.tabBarController {
            let tabBarHeight = tabBarController.tabBar.frame.size.height
            bottomHeight += tabBarHeight
        }
        return AppDelegate.instance.safeAreaInsets.bottom + bottomHeight + 120
    }
}
