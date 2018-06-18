//
//  ImageContainerView.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/17/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

@IBDesignable
class ImageContainerView: UIView {
    
    let imageView = UIImageView()
    @IBInspectable var image: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.imageView.frame = self.bounds
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)
        self.addObserver(self, forKeyPath: #keyPath(layer.cornerRadius), options: [.new], context: nil)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: #keyPath(layer.cornerRadius), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(layer.cornerRadius),
            let newValue = change?[NSKeyValueChangeKey.newKey],
            let newCornerRadius = newValue as? CGFloat {
            self.imageView.layer.cornerRadius = newCornerRadius
        }
    }
    
}
