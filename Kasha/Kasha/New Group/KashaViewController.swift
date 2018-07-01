//
//  KashaViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/6/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

class KashaViewController: UIViewController, MusicAwareTabBarControllerListener {
    
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
        if self.allowsSearch() {
            self.navigationItem.searchController = self.searchController
            guard let searchResultsVC = self.searchController.searchResultsController as? SearchResultsViewController else {
                assert(false, "searchResultsController was not an instance of SearchResultsViewController")
                return
            }
            self.searchController.searchResultsUpdater = searchResultsVC
//            self.searchController.hidesNavigationBarDuringPresentation = false
            self.definesPresentationContext = true
        }
        
        if let musicAwareTabBarController = self.musicAwareTabBarController {
            if musicAwareTabBarController.miniPlayerIsHidden {
                self.musicAwareTabBarController(musicAwareTabBarController, didHideMiniMusicPlayerView: musicAwareTabBarController.miniPlayer)
            } else {
                self.musicAwareTabBarController(musicAwareTabBarController, didShowMiniMusicPlayerView: musicAwareTabBarController.miniPlayer)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.isFirstLayout {
            self.doFirstLayoutAnimation()
        }
        self.isFirstLayout = false
    }
    
    // MARK: - Intro Animation
    func doFirstLayoutAnimation() {
        //Override
    }
    
    // MARK: - Search
    func allowsSearch() -> Bool {
        //Override
        return false
    }
    
    // MARK: - MusicAwareTabBarControllerListener
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController, willMoveMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView, toFrame frame: CGRect) {
        //Override
    }
    
    func musicAwareTabBarController(_ tabBarController: MusicAwareTabBarController, didShowMiniMusicPlayerView miniMusicPlayerView: MiniMusicPlayerView) {
        //Override
        if let scrollView = self.scrollViewToInsetForMiniPlayer() {
            scrollView.contentInset.bottom = miniMusicPlayerView.bounds.size.height + 10.0
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

}
