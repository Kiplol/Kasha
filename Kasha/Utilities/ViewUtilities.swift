//
//  ViewUtilities.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    var flowLayout: UICollectionViewFlowLayout? {
        return self.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    func usableWidth() -> CGFloat {
        var width = self.bounds.size.width - self.contentInset.left - self.contentInset.right
        if let flowLayout = self.flowLayout {
            width -= flowLayout.sectionInset.left
            width -= flowLayout.sectionInset.right
        }
        return width
    }
    
}
