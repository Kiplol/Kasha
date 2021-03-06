//
//  ViewUtilities.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/14/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer
import UIKit

//typealias ColorSet = (background: UIColor?, primary: UIColor?, secondary: UIColor?, detail: UIColor?)

extension UIView {
    
    func applyAlbumStyleShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 3.0
        self.clipsToBounds = false
    }
    
    func applyAlbumStyleRoundedCorners() {
        self.layer.cornerRadius = 10.0
    }
    
    func applyAlbumsStyle() {
        self.applyAlbumStyleRoundedCorners()
        self.applyAlbumStyleShadow()
    }
    
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = self.layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            guard let color = newValue else {
                self.layer.shadowColor = nil
                return
            }
            self.layer.shadowColor = color.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return self.layer.shadowOpacity
        }
        set {
            self.layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        set {
            self.layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            guard let color = newValue else {
                self.layer.borderColor = nil
                return
            }
            self.layer.borderColor = color.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    func roundCorners() {
        let dimension = min(self.bounds.size.height, self.bounds.size.width)
        self.cornerRadius = dimension * 0.5
    }
    
}

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

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    func tint(_ tintColor: UIColor?) -> UIImage {
        guard let tintColor = tintColor else { return self }
        return modifiedImage { context, rect in
            context.setBlendMode(.multiply)
            context.clip(to: rect, mask: self.cgImage!)
            tintColor.setFill()
            context.fill(rect)
        }
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> Void) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        return newImage
    }
}

extension Array where Element: UIViewController {
    
    func indexOfNavigationControllerWithRootViewController<T: UIViewController>(ofClass vcClass: T.Type) -> Array.Index? {
        return self.index {
            if $0 is T {
                return true
            } else if let navController = $0 as? UINavigationController {
                return navController.viewControllers.first is T
            } else {
                return false
            }
        }
    }
    
}

extension UIWindow {
    
    func removeAndReaddAllSubviews() {
        self.subviews.forEach {
            $0.removeFromSuperview()
            self.addSubview($0)
        }
    }
    
}

extension UIImageView {
    
    func setSongImage(_ song: MediaLibraryHelper.Song, beforeSet: ((UIImage) -> (UIImage?))? = nil) {
        let bounds = self.bounds
        DispatchQueue.global(qos: .default).async {
            let image = song.artwork?.image(at: CGSize(width: bounds.size.width, height: bounds.size.height))
            DispatchQueue.main.async {
                let imageForClosure = image ?? #imageLiteral(resourceName: "placeholder-artwork")
                self.image = beforeSet?(imageForClosure) ?? imageForClosure
            }
        }
    }
    
    func setAlbumImage(_ album: MediaLibraryHelper.Album, beforeSet: ((UIImage) -> (UIImage?))? = nil) {
        let bounds = self.bounds
        DispatchQueue.global(qos: .default).async {
            let image = album.representativeItem?.artwork?.image(at: CGSize(width: bounds.size.width, height: bounds.size.height))
            DispatchQueue.main.async {
                let imageForClosure = image ?? #imageLiteral(resourceName: "placeholder-artwork")
                self.image = beforeSet?(imageForClosure) ?? imageForClosure
            }
        }
    }
    
    func setPlaylistImage(_ playlist: MediaLibraryHelper.Playlist, beforeSet: ((UIImage) -> (UIImage?))? = nil) {
        let bounds = self.bounds
        DispatchQueue.global(qos: .default).async {
            let image = playlist.representativeItem?.artwork?.image(at: CGSize(width: bounds.size.width, height: bounds.size.height))
            DispatchQueue.main.async {
                let imageForClosure = image ?? #imageLiteral(resourceName: "placeholder-artwork")
                self.image = beforeSet?(imageForClosure) ?? imageForClosure
            }
        }
    }
    
}
