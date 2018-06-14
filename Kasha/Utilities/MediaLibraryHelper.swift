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
    func allArists() -> [MPMediaItemCollection] {
        return MPMediaQuery.artists().collections ?? []
    }
    
    func allArtistSections() -> [MPMediaQuerySection] {
        return MPMediaQuery.artists().collectionSections ?? []
    }
    
    func artist(forSection section: MPMediaQuerySection, atIndex index: Int) -> MPMediaItemCollection {
        let currentLocation = section.range.location + index
        return MediaLibraryHelper.shared.allArists()[currentLocation]
    }
    
    // MARK: - Albums
    func allAlbums() -> [MPMediaItemCollection] {
        return MPMediaQuery.albums().collections ?? []
    }
    
    func albums(forArtist artist: MPMediaItemCollection) -> [MPMediaItemCollection] {
        let artistID = artist.persistentID
        let albumsQuery = MPMediaQuery.albums()
        albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: artistID,
                                                                forProperty: MPMediaItemPropertyArtistPersistentID))
        return albumsQuery.collections ?? []
    }

}
