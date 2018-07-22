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
        AppDelegate.instance.show(album: album, animated: true)
    }
    
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didSelectArtist artist: MediaLibraryHelper.Artist) {
        AppDelegate.instance.show(artist: artist, animated: true)
    }
    
    func searchResultsViewController(_ searchResultsViewController: SearchResultsViewController, didSelectPlaylist playlist: MediaLibraryHelper.Playlist) {
        AppDelegate.instance.show(playlist: playlist, animated: true)
    }
    
    // MARK: - Gestalt
    func apply(theme: Theme) {
        //Override
        self.viewIfLoaded?.backgroundColor = theme.backgroundColor
    }
}
