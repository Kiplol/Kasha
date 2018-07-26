//
//  ArtistViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/18/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import SwiftIcons
import UIKit

class ArtistViewController: KashaViewController, UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout {
    
    private static let controlsCellID = "controlsCellID"
    private static let albumCellID = "albumCellID"
    private static let allSongsCellID = "allSongsCellID"
    private static let unknownAlbumCellID = "unknownAlbumCellID"
    private static let sectionHeaderID = "sectionHeaderID"
    
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
    override var previewActionItems: [UIPreviewActionItem] {
        let playAllPreviewAction = UIPreviewAction(title: "Play All", style: .default) { _, _ in
            self.playAll()
        }
        let shuffleAllPreviewAction = UIPreviewAction(title: "Shuffle All", style: .default) { _, _ in
            self.shuffleAll()
        }
        return [playAllPreviewAction, shuffleAllPreviewAction]
    }
    
    class func with(artist: MediaLibraryHelper.Artist) -> ArtistViewController {
        guard let artistVC = UIStoryboard(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "artist") as? ArtistViewController else {
                preconditionFailure("Couldn't instantiate a ArtistViewController from storyboard")
        }
        artistVC.artist = artist
        return artistVC
    }
    
    // MARK: - KashaViewController
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
        self.collectionView.register(albumCellNib, forCellWithReuseIdentifier: ArtistViewController.albumCellID)
        self.collectionView.register(albumCellNib, forCellWithReuseIdentifier: ArtistViewController.allSongsCellID)
        self.collectionView.register(albumCellNib, forCellWithReuseIdentifier: ArtistViewController.unknownAlbumCellID)
        
        let sectionHeaderNib = UINib(nibName: "SectionHeaderCollectionReusableView", bundle: Bundle.main)
        self.collectionView.register(sectionHeaderNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                     withReuseIdentifier: ArtistViewController.sectionHeaderID)
        self.collectionView.flowLayout?.sectionHeadersPinToVisibleBounds = true
        
        let controlsNib = UINib(nibName: "ControlsCollectionViewCell", bundle: Bundle.main)
        self.collectionView.register(controlsNib, forCellWithReuseIdentifier: ArtistViewController.controlsCellID)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let albumVC = segue.destination as? AlbumViewController {
            if let album = sender as? MediaLibraryHelper.Album {
                albumVC.album = album
            } else if let songs = sender as? [MediaLibraryHelper.Song] {
                albumVC.title = self.title
                albumVC.songs = songs
            }
        }
    }
    
    // MARK: - Helpers
    private func populateSections() {
        self.sections.removeAll()
        
        // Controls
        self.sections.append(Section(title: nil, rows: [Row(cellReuseIdentifier: ArtistViewController.controlsCellID)]))
        
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
        
        // Unknown Album
        let songsFromUnknownAlbums = MediaLibraryHelper.shared.allSongsForUnknownAlbum(forArtist: self.artist)
        if !songsFromUnknownAlbums.isEmpty {
            let unknownAlbumSection = Section(title: "Unknown Album", rows: [Row(data: songsFromUnknownAlbums,
                                                                                cellReuseIdentifier: ArtistViewController.unknownAlbumCellID)])
            self.sections.append(unknownAlbumSection)
        }
    }
    
    private func playAll() {
        let allSongs = MediaLibraryHelper.shared.allSongs(forArtist: self.artist)
        if let firstSong = allSongs.first {
            MediaLibraryHelper.shared.turnOnShuffle()
            MediaLibraryHelper.shared.play(firstSong, inQueue: allSongs)
        }
    }
    
    private func shuffleAll() {
        let allSongs = MediaLibraryHelper.shared.allSongs(forArtist: self.artist)
        guard !allSongs.isEmpty else {
            return
        }
        let randomIndex = Int(arc4random_uniform(UInt32(allSongs.count)))
        let song = allSongs[randomIndex]
        MediaLibraryHelper.shared.play(song, inQueue: allSongs)
        MediaLibraryHelper.shared.turnOnShuffle()
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
            case ArtistViewController.unknownAlbumCellID:
                albumCell.updateAsUnknownAlbum(forArtist: self.artist, withSongs: row.data as? [MediaLibraryHelper.Song])
            default:
                break
            }
        } else if let controlsCell = cell as? ControlsCollectionViewCell {
            controlsCell.buttonPlayAction = { [weak self] _ in
                self?.playAll()
            }
            controlsCell.buttonShuffleAction = { [weak self] _ in
                self?.shuffleAll()
            }
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
                                                  withReuseIdentifier: ArtistViewController.sectionHeaderID,
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
        guard let data = self.sections[indexPath.section].rows[indexPath.row].data else {
            return
        }
        if let album = data as? MediaLibraryHelper.Album {
            self.performSegue(withIdentifier: "artistToAlbum", sender: album)
        } else if let songs = data as? [MediaLibraryHelper.Song] {
            self.performSegue(withIdentifier: "artistToAlbum", sender: songs)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let title = self.sections[section].title else {
            return .zero
        }
        return SectionHeaderCollectionReusableView.sizeConstrained(toWidth: collectionView.usableWidth(),
                                                                   withData: title)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns = max(floor((collectionView.usableWidth() / AlbumCollectionViewCell.idealWidth)), 2.0)
        let interItemSpace = collectionView.flowLayout?.minimumInteritemSpacing ?? 0.0
        let width = floor(collectionView.usableWidth() * (1.0 / numberOfColumns)) - (interItemSpace / numberOfColumns)
        let row = self.sections[indexPath.section].rows[indexPath.row]
        let cellID = row.cellReuseIdentifier
        switch cellID {
        case ArtistViewController.controlsCellID:
            return ControlsCollectionViewCell.sizeConstrained(toWidth: collectionView.usableWidth(), withData: row.data)
        default:
            return AlbumCollectionViewCell.sizeConstrained(toWidth: width, withData: row.data)
        }
    }

}

extension ArtistViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location) else {
            return nil
        }
        
        let row = self.sections[indexPath.section].rows[indexPath.row]
        if let album = row.data as? MediaLibraryHelper.Album {
            return AlbumViewController.with(album: album)
        } else if let songs = row.data as? [MediaLibraryHelper.Song] {
            let albumVC = AlbumViewController.with(songs: songs)
            albumVC.title = self.title
            return albumVC
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
    }
    
}
