//
//  PlayerViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/5/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class PlayerViewController: KashaViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var imageArtwork: ImageContainerView!
    
    // MARK: - ivars
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    var initialBackgroundColor: UIColor?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        if let initialBackgroundColor = self.initialBackgroundColor {
            self.view.backgroundColor = initialBackgroundColor
        }
        self.update(withNowplayingItem: MediaLibraryHelper.shared.musicPlayer.nowPlayingItem)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.update(withNowplayingItem: MediaLibraryHelper.shared.musicPlayer.nowPlayingItem)
    }
    
    // MARK: - Helpers
    private func update(withNowplayingItem nowPlayingItem: MediaLibraryHelper.Song?) {
        self.updateColors(withNowplayingItem: nowPlayingItem)
        guard let nowPlayingItem = nowPlayingItem else {
            self.imageArtwork.image = #imageLiteral(resourceName: "placeholder-artwork")
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            let image = nowPlayingItem.artwork?.image(at: CGSize(width: 80.0, height: 80.0))
            DispatchQueue.main.async {
                self.imageArtwork.image = image ?? #imageLiteral(resourceName: "placeholder-artwork")
            }
        }
    }
    
    // MARK: Colors
    private func updateColors(withNowplayingItem nowPlayingItem: MediaLibraryHelper.Song?) {
        guard let nowPlayingItem = nowPlayingItem else {
            self.resetColors()
            return
        }
        DispatchQueue.global(qos: .default).async {
            guard let image = nowPlayingItem.artwork?.image(at: CGSize(width: 54.0, height: 54.0)) else {
                DispatchQueue.main.async {
                    self.resetColors()
                }
                return
            }
            let (background, primary, secondary, detail) = image.colors()
            DispatchQueue.main.async {
                self.view.backgroundColor = background
            }
        }
    }
    
    private func resetColors() {
        self.view.backgroundColor = .white
    }

}
