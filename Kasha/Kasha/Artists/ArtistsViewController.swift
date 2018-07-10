//
//  ArtistsViewController.swift
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

class ArtistsViewController: KashaViewController, UITableViewDataSource, UITableViewDelegate {
    
    private static let cellID = "artistCellID"

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indexView: BDKCollectionIndexView!
    
    // MARK: - ivars
    private let artistSections = MediaLibraryHelper.shared.allArtistSections()
    
    // MARK: - KashaViewController
    override func commonInit() {
        super.commonInit()
        self.title = "Artists"
        self.tabBarItem.image = #imageLiteral(resourceName: "artists")
    }
    
    override func doFirstLayoutAnimation() {
        super.doFirstLayoutAnimation()
        let animations = [AnimationType.from(direction: .bottom, offset: 30.0)]
        self.tableView.reloadData()
        UIView.animate(views: self.tableView.visibleCells, animations: animations, completion: nil)
    }
    
    override func allowsSearch() -> Bool {
        return true
    }
    
    override func scrollViewToInsetForMiniPlayer() -> UIScrollView? {
        return self.tableView
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.traitCollection.forceTouchCapability == .available {
            self.registerForPreviewing(with: self, sourceView: self.tableView)
        }

        //Table View
        let artistCellNib = UINib(nibName: "ArtistTableViewCell", bundle: Bundle.main)
        self.tableView.register(artistCellNib, forCellReuseIdentifier: ArtistsViewController.cellID)
        
        //Section Index
        self.indexView.addTarget(self, action: #selector(ArtistsViewController.indexViewValueChanged(sender:)),
                                 for: .valueChanged)
        self.indexView.indexTitles = self.artistSections.compactMap { $0.title }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedRow, animated: animated)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let artistVC = segue.destination as? ArtistViewController, let artist = sender as? MPMediaItemCollection {
            artistVC.artist = artist
        }
    }
    
    // MARK: - Helpers
    private func artist(forIndexPath indexPath: IndexPath) -> MPMediaItemCollection {
        let section = self.artistSections[indexPath.section]
        return MediaLibraryHelper.shared.artist(forSection: section, atIndex: indexPath.row)
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.artistSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artistSections[section].range.length
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArtistsViewController.cellID, for: indexPath)
        if let artistCell = cell as? ArtistTableViewCell {
            artistCell.update(withArtist: self.artist(forIndexPath: indexPath))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ArtistTableViewCell.sizeConstrained(toWidth: tableView.frame.size.width,
                                                   withData: self.artist(forIndexPath: indexPath)).height
    }
    
    // MARK: Section Indeces
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.artistSections.compactMap { $0.title }[section]
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artist = self.artist(forIndexPath: indexPath)
        self.performSegue(withIdentifier: "artistsToArtist", sender: artist)
    }

}

extension ArtistsViewController {
    // MARK: - Index View
    @objc func indexViewValueChanged(sender: BDKCollectionIndexView) {
        let path = IndexPath(item: 0, section: Int(sender.currentIndex))
        self.tableView.scrollToRow(at: path, at: .top, animated: false)
    }
}

extension ArtistsViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tableView.indexPathForRow(at: location) else {
            return nil
        }
        let artist = self.artist(forIndexPath: indexPath)
        let artistVC = ArtistViewController.with(artist: artist)
        return artistVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
    }
}
