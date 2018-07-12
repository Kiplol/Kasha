//
//  HorizontalItemView.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/8/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

protocol HorizontalItemsViewDelegate: class {
    func horizontalItemsView(_ horizontalItemsView: HorizontalItemsView, didSelectItem item: Any)
}

class HorizontalItemsView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    private static let albumCellReuseID = "albumCellID"
    
    // MARK: - IBOutlets
    private(set) var collectionView: UICollectionView! {
        didSet {
            let albumCellNib = UINib(nibName: "AlbumCollectionViewCell", bundle: Bundle.main)
            self.collectionView.register(albumCellNib, forCellWithReuseIdentifier: HorizontalItemsView.albumCellReuseID)
        }
    }
    
    // MARK: - ivars
    private var sections: [Section] = []
    var items: [Any] = [] {
        didSet {
            self.populateSections()
        }
    }
    weak var delegate: HorizontalItemsViewDelegate?
    
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset.bottom = 10.0
        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView.frame = self.bounds
        self.populateSections()
        self.addSubview(self.collectionView)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layout = self.collectionView.flowLayout {
            var usableHeight = self.collectionView.bounds.size.height
            if let layout = self.collectionView.flowLayout {
                usableHeight -= (layout.sectionInset.bottom + layout.sectionInset.top)
            }
            layout.itemSize = CGSize(width: usableHeight, height: usableHeight)
        }
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Helpers
    private func populateSections() {
        self.sections.removeAll()
        
        let albumsSection = Section(title: "Recently Added", rows: self.items.map {
            Row(data: $0, cellReuseIdentifier: HorizontalItemsView.albumCellReuseID)
        })
        if !albumsSection.rows.isEmpty {
            self.sections.append(albumsSection)
        }
        
        self.collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sections[section].rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = self.sections[indexPath.section].rows[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: row.cellReuseIdentifier, for: indexPath)
        if let albumCell = cell as? AlbumCollectionViewCell, let album = row.data as? MediaLibraryHelper.Album {
            albumCell.update(withAlbum: album)
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.sections[indexPath.section].rows[indexPath.row].data else {
            return
        }
        self.delegate?.horizontalItemsView(self, didSelectItem: item)
    }
    
}
