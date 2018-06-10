//
//  MediaLibraryHelper.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/10/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer

class MediaLibraryHelper: NSObject {
    
    static let shared = MediaLibraryHelper()
    
    // MARK: - Artists
    func allArists() -> [MPMediaItemCollection]? {
        return MPMediaQuery.artists().collections
    }
    
    func allArtistSections() -> [MPMediaQuerySection]? {
        return MPMediaQuery.artists().collectionSections
    }

}
