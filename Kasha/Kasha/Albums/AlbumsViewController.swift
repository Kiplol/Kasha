//
//  AlbumsViewController.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class AlbumsViewController: KashaViewController {
    
    // MARK: - ivars
    private let albumSections = MediaLibraryHelper.shared.allAlbumSections()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
