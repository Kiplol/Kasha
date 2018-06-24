//
//  MediaLibraryHelper.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/10/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import MediaPlayer

class MediaLibraryHelper: NSObject {
    
    typealias Album = MPMediaItemCollection
    typealias Artist = MPMediaItemCollection
    typealias Song = MPMediaItem
    
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    static let shared = MediaLibraryHelper()
    
    // MARK: - Artists
    func allArists() -> [MPMediaItemCollection] {
        return MPMediaQuery.artists().collections ?? []
    }
    
    func allArtistSections() -> [MPMediaQuerySection] {
        return MPMediaQuery.artists().collectionSections ?? []
    }
    
    func artist(forSection section: MPMediaQuerySection, atIndex index: Int) -> Artist {
        let currentLocation = section.range.location + index
        return MediaLibraryHelper.shared.allArists()[currentLocation]
    }
    
    // MARK: - Albums
    func allAlbums() -> [Album] {
        return MPMediaQuery.albums().collections ?? []
    }
    
    func allAlbumSections() -> [MPMediaQuerySection] {
        return MPMediaQuery.albums().collectionSections ?? []
    }
    
    func album(forSection section: MPMediaQuerySection, atIndex index: Int) -> Album {
        let currentLocation = section.range.location + index
        return MediaLibraryHelper.shared.allAlbums()[currentLocation]
    }
    
    func albums(forArtist artist: Artist) -> [Album] {
        let artistID = artist.persistentID
        let albumsQuery = MPMediaQuery.albums()
        albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: artistID,
                                                                forProperty: MPMediaItemPropertyArtistPersistentID))
        return albumsQuery.collections ?? []
    }
    
    // MARK: - Songs
    func allSongs(forArtist artist: MPMediaItemCollection) -> [Song] {
        let artistID = artist.persistentID
        let songQuery = MPMediaQuery.songs()
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: artistID,
                                                              forProperty: MPMediaItemPropertyArtistPersistentID))
        return songQuery.items ?? []
    }
    
    func allSongs(fromAlbum album: MPMediaItemCollection) -> [Song] {
        let albumID = album.persistentID
        let songQuery = MPMediaQuery.songs()
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: albumID,
                                                              forProperty: MPMediaItemPropertyAlbumPersistentID))
        return songQuery.items ?? []
    }
    
    // MARK: - Playback
    func play(_ song: Song, inQueue queue: [Song]? = nil) {
        if let queue = queue {
            self.musicPlayer.setQueue(with: MPMediaItemCollection(items: queue))
            self.musicPlayer.nowPlayingItem = song
        } else {
            self.musicPlayer.setQueue(with: MPMediaItemCollection(items: [song]))
        }
        self.musicPlayer.prepareToPlay { [unowned self] error in
            guard error == nil else {
                debugPrint(error ?? "")
                return
            }
            self.musicPlayer.play()
        }
    }

}
