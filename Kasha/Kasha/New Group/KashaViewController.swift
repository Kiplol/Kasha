//
//  KashaViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/6/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Gestalt
import MediaPlayer
import UIKit

class KashaViewController: UIViewController, MusicAwareTabBarControllerListener, SearchResultsViewControllerDelegate {
    
    private var isFirstLayout = true
    private lazy var searchController = UISearchController(searchResultsController: SearchResultsViewController())

    // MARK: - Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        //Override
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.apply(theme: theme)
        }
        if self.allowsSearch() {
            self.navigationItem.searchController = self.searchController
            guard let searchResultsVC = self.searchController.searchResultsController as? SearchResultsViewController else {
                assert(false, "searchResultsController was not an instance of SearchResultsViewController")
                return
            }
            searchResultsVC.delegate = self
            self.searchController.searchResultsUpdater = searchResultsVC
//            self.searchController.hidesNavigationBarDuringPresentation = false
            self.definesPresentationContext = true
        }
        
        self.adjustForMusicAwareTabBarController()
        
//        let shadowView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: 5.0))
//        shadowView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
//        self.view.addSubview(shadowView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.isFirstLayout {
            self.doFirstLayoutAnimation()
        }
        self.isFirstLayout = false
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if self.musicAwareTabBarController != nil {
            self.adjustForMusicAwareTabBarController()
        }
    }
    // MARK: - Intro Animation
    func doFirstLayoutAnimation() {
        //Override
    }
    
    // MARK: - Search
    func allowsSearch() -> Bool {
        //Override
        return true
    }
    
    // MARK: - MusicAwareTabBarController
    func adjustForMusicAwareTabBarController() {
        if let musicAwareTabBarController = self.musicAwareTabBarController {
            if musicAwareTabBarController.miniPlayerIsHidden {
                self.musicAwareTabBarController(musicAwareTabBarController, didHideMiniMusicPlayerView: musicAwareTabBarController.miniPlayer)
            } else {
                self.musicAwareTabBarController(musicAwareTabBarController, didShowMiniMusicPlayerView: musicAwareTabBarController.miniPlayer)
            }
        }
    }
    
    // MARK: - MusicAwareTabBarControllerListener
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController, willMoveMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView, toFrame frame: CGRect) {
        //Override
    }
    
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController, didShowMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView) {
        //Override
        if let scrollView = self.scrollViewToInsetForMiniPlayer() {
            scrollView.contentInset.bottom = miniMusicPlayerView.bounds.size.height + MusicAwareTabBarController.padding
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }
    
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController, didHideMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView) {
        //Override
        if let scrollView = self.scrollViewToInsetForMiniPlayer() {
            scrollView.contentInset.bottom = 0.0
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }
    
    func scrollViewToInsetForMiniPlayer() -> UIScrollView? {
        //Override
        return nil
    }
    
    // MARK: - SearchResultsViewControllerDelegate
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didSelectAlbum album: MediaLibraryHelper.Album) {
        guard let albumVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "songs") as? AlbumViewController else {
            preconditionFailure("Couldn't instantiant an ArtistViewController from its storyboard.")
        }
        albumVC.album = album
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                navigationController.show(albumVC, sender: album)
            })
        } else {
            self.show(albumVC, sender: album)
        }
    }
    
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didSelectArtist artist: MediaLibraryHelper.Artist) {
        guard let artistVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "artist") as? ArtistViewController else {
            preconditionFailure("Couldn't instantiant an ArtistViewController from its storyboard.")
        }
        artistVC.artist = artist
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                navigationController.show(artistVC, sender: artist)
            })
        } else {
            self.show(artistVC, sender: artist)
        }
    }
    
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didSelectPlaylist playlist: MediaLibraryHelper.Playlist) {
        guard let albumVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "songs") as? AlbumViewController else {
            preconditionFailure("Couldn't instantiant an ArtistViewController from its storyboard.")
        }
        albumVC.songs = playlist.items
        albumVC.title = playlist.name
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                navigationController.show(albumVC, sender: playlist)
            })
        } else {
            self.show(albumVC, sender: playlist)
        }
    }
    
    // MARK: - Gestalt
    func apply(theme: Theme) {
        //Override
    }
}
