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
    private var backgroundColor: UIColor = .white
    private var primaryColor: UIColor = .kashaPrimaryColor
    private var secondaryColor: UIColor = .kashaSecondaryColor
    private var detailColor: UIColor = .black
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        self.applyColors()
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
    func applyColors(background: UIColor? = nil, primary: UIColor? = nil, secondary: UIColor? = nil, detail: UIColor? = nil) {
        if let background = background {
            self.backgroundColor = background
        }
        if let primary = primary {
            self.primaryColor = primary
        }
        if let secondary = secondary {
            self.secondaryColor = secondary
        }
        if let detail = detail {
            self.detailColor = detail
        }
        
        DispatchQueue.main.async {
            guard let view = self.viewIfLoaded else {
                return
            }
            //view.backgroundColor = self.backgroundColor
            let shadowColor = view.backgroundColor!.isDark ? UIColor.white : UIColor.black
            [self.buttonPause, self.buttonPlay].forEach { $0?.backgroundColor = shadowColor.alpha(0.7) }
            self.allButtons.forEach {
                $0.tintColor = self.detailColor
                $0.layer.shadowColor = shadowColor.cgColor
            }
        }
    }
    
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
            self.applyColors(background: background, primary: primary, secondary: secondary, detail: detail)
        }
    }
    
    private func resetColors() {
        self.view.backgroundColor = .white
    }

}
