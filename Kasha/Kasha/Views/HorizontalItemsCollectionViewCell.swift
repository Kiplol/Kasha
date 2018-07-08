//
//  HorizontalItemsCollectionViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/8/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class HorizontalItemsCollectionViewCell: UICollectionViewCell, SelfSizing {
    
    @IBOutlet weak var horizontalItemsView: HorizontalItemsView!
    
    // MARK: - SelfSizing
    static func sizeConstrained(toWidth width: CGFloat, withData: Any?) -> CGSize {
        return CGSize(width: width, height: 120.0)
    }
}
