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

class AlbumsViewController: KashaViewController, UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout, HorizontalItemsViewDelegate {
    
    private static let albumCellID = "albumCellID"
    private static let horizontalItemsCellID = "horizontalItemsCellID"
    private static let sectionHeaderID = "sectionHeaderID"
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indexView: BDKCollectionIndexView!
    
    // MARK: - ivars
    private var sections: [Section] = []
    private var recentlyAddedSection: Section?

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
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        self.collectionView.backgroundColor = theme.backgroundColor
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.traitCollection.forceTouchCapability == .available {
            self.registerForPreviewing(with: self, sourceView: self.collectionView)
        }
        
        //Collection View
        let albumCellNib = UINib(nibName: "AlbumCollectionViewCell", bundle: Bundle.main)
        self.collectionView.register(albumCellNib, forCellWithReuseIdentifier: AlbumsViewController.albumCellID)
        
        let horizontalItemsCellNib = UINib(nibName: "HorizontalItemsCollectionViewCell", bundle: Bundle.main)
        self.collectionView.register(horizontalItemsCellNib, forCellWithReuseIdentifier: AlbumsViewController.horizontalItemsCellID)
        
        let sectionHeaderNib = UINib(nibName: "SectionHeaderCollectionReusableView", bundle: Bundle.main)
        self.collectionView.register(sectionHeaderNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                     withReuseIdentifier: AlbumsViewController.sectionHeaderID)
        self.collectionView.flowLayout?.sectionHeadersPinToVisibleBounds = true
        
        //Section Index
        self.indexView.addTarget(self, action: #selector(AlbumsViewController.indexViewValueChanged(sender:)),
                                 for: .valueChanged)
        
        self.populateSections()
        DispatchQueue.global(qos: .userInitiated).async {
            let recentlyAddedAlbums = MediaLibraryHelper.shared.recentlyAddedAlbums()
            if !recentlyAddedAlbums.isEmpty {
                DispatchQueue.main.async {
                    self.populateSections(recentlyAdded: recentlyAddedAlbums)
                }
            }
        }
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        if let flowLayout = self.collectionView.flowLayout {
//            let numberOfColumns = max(floor((self.collectionView.usableWidth() / AlbumCollectionViewCell.idealWidth)), 2.0)
//            let interItemSpace = self.collectionView.flowLayout?.minimumInteritemSpacing ?? 0.0
//            let width = floor(self.collectionView.usableWidth() * (1.0 / numberOfColumns)) - (interItemSpace / numberOfColumns)
//            flowLayout.itemSize = AlbumCollectionViewCell.sizeConstrained(toWidth: width, withData: nil)
//        }
//    }
    
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
    private func populateSections(recentlyAdded: [MediaLibraryHelper.Album]? = nil) {
        self.sections.removeAll()
        var titles: [String] = []
        
        let previouslyContainedRecentlyAddedSection = self.recentlyAddedSection != nil
        if let recentlyAdded = recentlyAdded, !recentlyAdded.isEmpty {
            let recentSection = Section(title: "Recently Added", rows: [Row(data: recentlyAdded, cellReuseIdentifier: AlbumsViewController.horizontalItemsCellID)])
            self.sections.append(recentSection)
            self.recentlyAddedSection = recentSection
            titles.append("-")
        } else {
            self.recentlyAddedSection = nil
        }
        let containsRecentlyAddedSection = self.recentlyAddedSection != nil
        
        let albumSections = MediaLibraryHelper.shared.allAlbumSections().map {
            Section(title: $0.title, rows: MediaLibraryHelper.shared.allAlbums(inSection: $0).map {
                Row(data: $0, cellReuseIdentifier: AlbumsViewController.albumCellID)
            })
        }
        if !albumSections.isEmpty {
            self.sections.append(contentsOf: albumSections)
            albumSections.map { $0.title ?? "" }.forEach { titles.append($0) }
        }
        
        self.indexView.indexTitles = titles
        self.collectionView.performBatchUpdates({
            if previouslyContainedRecentlyAddedSection != containsRecentlyAddedSection {
                if containsRecentlyAddedSection {
                    self.collectionView.insertSections([0])
                } else {
                    self.collectionView.deleteSections([0])
                }
            } else {
                
            }
        }, completion: nil)
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
        let row = self.sections[indexPath.section].rows[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: row.cellReuseIdentifier,
                                                      for: indexPath)
        
        if let albumCell = cell as? AlbumCollectionViewCell,
            let album = row.data as? MediaLibraryHelper.Album {
            albumCell.update(withAlbum: album)
        } else if let horizontalItemsCell = cell as? HorizontalItemsCollectionViewCell,
            let recentlyAddedAlbums = row.data as? [MediaLibraryHelper.Album] {
            horizontalItemsCell.horizontalItemsView.items = recentlyAddedAlbums
            horizontalItemsCell.horizontalItemsView.delegate = self
        }
        return cell
    }
    
    // MARK: Section Headers
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            guard let title = self.sections[indexPath.section].title else {
                preconditionFailure("No title for ArtistViewController section")
                
            }
            let headerView = collectionView
                .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                  withReuseIdentifier: AlbumsViewController.sectionHeaderID,
                                                  for: indexPath)
            if let sectionHeaderView = headerView as? SectionHeaderCollectionReusableView {
                sectionHeaderView.text = title
            }
            return headerView
        default:
            preconditionFailure("Unexpected element kind")
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let album = row.data as? MediaLibraryHelper.Album {
            self.performSegue(withIdentifier: "albumsToAlbum", sender: album)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if row.data is [MediaLibraryHelper.Album] {
            return HorizontalItemsCollectionViewCell.sizeConstrained(toWidth: collectionView.usableWidth(), withData: row.data)
        } else if row.data is MediaLibraryHelper.Album {
            let numberOfColumns = max(floor((self.collectionView.usableWidth() / AlbumCollectionViewCell.idealWidth)), 2.0)
            let interItemSpace = self.collectionView.flowLayout?.minimumInteritemSpacing ?? 0.0
            let width = floor(collectionView.usableWidth() * (1.0 / numberOfColumns)) - (interItemSpace / numberOfColumns)
            return AlbumCollectionViewCell.sizeConstrained(toWidth: width, withData: nil)
        } else {
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let title = self.sections[section].title else {
            return .zero
        }
        return SectionHeaderCollectionReusableView.sizeConstrained(toWidth: collectionView.usableWidth(),
                                                                   withData: title)
    }
    
    // MARK: - HorizontalItemsViewDelegate
    func horizontalItemsView(_ horizontalItemsView: HorizontalItemsView, didSelectItem item: Any) {
        if let album = item as? MediaLibraryHelper.Album {
            self.performSegue(withIdentifier: "albumsToAlbum", sender: album)
        }
    }
}

extension AlbumsViewController {
    // MARK: - Index View
    @objc func indexViewValueChanged(sender: BDKCollectionIndexView) {
        let path = IndexPath(item: 0, section: Int(sender.currentIndex))
        self.collectionView.scrollToItem(at: path, at: .top, animated: false)
        let newYOffset = self.collectionView.contentOffset.y - SectionHeaderCollectionReusableView.sizeConstrained(toWidth: self.collectionView.bounds.size.width, withData: nil).height
        self.collectionView.setContentOffset(CGPoint(x: 0.0, y: newYOffset), animated: false)
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
        } else if let horizontalItemsCell = collectionView.cellForItem(at: indexPath) as? HorizontalItemsCollectionViewCell,
            let innerIndexPath = horizontalItemsCell.horizontalItemsView.collectionView.indexPathForItem(at: horizontalItemsCell.horizontalItemsView.collectionView.convert(location, from: self.collectionView)),
            let album = horizontalItemsCell.horizontalItemsView.sections[innerIndexPath.section].rows[innerIndexPath.row].data as? MediaLibraryHelper.Album {
            let albumVC = AlbumViewController.with(album: album)
            return albumVC
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
    }
    
}
