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
    @IBOutlet weak var artworkContainer: UIView!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonPause: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet var allButtons: [UIButton]!
    
    // MARK: - ivars
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // MARK: - KashaViewController
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        let shadowColor = self.view.backgroundColor!.isDark ? UIColor.white : UIColor.black
        let playPauseBackgoundColor = theme.playerDetailColor.isDark ? UIColor.white : UIColor.black
        [self.buttonPause, self.buttonPlay].forEach {
            $0?.backgroundColor = playPauseBackgoundColor.alpha(0.7)
        }
        self.allButtons.forEach {
            $0.tintColor = theme.playerDetailColor
            $0.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        self.update(withNowplayingItem: MediaLibraryHelper.shared.musicPlayer.nowPlayingItem)
        
        self.imageArtwork.layer.cornerRadius = 15.0
        self.imageArtwork.layer.shadowRadius = 10.0
        self.artworkContainer.applyAlbumsStyle()
        self.artworkContainer.layer.cornerRadius = 20.0
        self.artworkContainer.layer.shadowRadius = 15.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.update(withNowplayingItem: MediaLibraryHelper.shared.musicPlayer.nowPlayingItem)
    }
    
    // MARK: - Helpers
    private func update(withNowplayingItem nowPlayingItem: MediaLibraryHelper.Song?) {
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
}
