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
    typealias Playlist = MPMediaPlaylist
    typealias PlaylistFolder = MPMediaItemCollection
    
    static let shared = MediaLibraryHelper()
    
    // MARK: - ivars
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private(set) var queue: MPMediaItemCollection = MPMediaItemCollection(items: []) {
        didSet {
            self.musicPlayer.setQueue(with: self.queue)
        }
    }
    
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
    
    // MARK: - Playlists
    func allPlaylists() -> [Playlist] {
        let playlistQuery = MPMediaQuery.playlists()
        return (playlistQuery.collections as? [Playlist] ?? []).filter { $0.count > 0 }
    }
    
    func allPlaylistFolders() -> [PlaylistFolder] {
        let playlistQuery = MPMediaQuery.playlists()
        let playlists = playlistQuery.collections as? [Playlist] ?? []
        return playlists.filter { $0.isFolder }
    }
    
    func allPlaylistsNotInFolders() -> [Playlist] {
        let playlists = self.allPlaylists()
        return playlists.filter { !$0.isFolder }.filter { $0.parentPersistentID == nil || $0.parentPersistentID == 0 }
    }

    func allPlaylists(inPlaylistFolder playlistFolder: PlaylistFolder) -> [Playlist]? {
        let playlistPersistentID = playlistFolder.persistentID
        let allPlaylists = self.allPlaylists()
        let matches = allPlaylists.filter { $0.parentPersistentID != nil }.filter {
            $0.parentPersistentID! == playlistPersistentID
        }
        return matches.isEmpty ? nil : matches
    }
    
    // MARK: - Playback
    func play(_ song: Song, inQueue queue: [Song]? = nil) {
        if let queue = queue {
            self.queue = MPMediaItemCollection(items: queue)
            self.musicPlayer.nowPlayingItem = song
        } else {
            self.queue = MPMediaItemCollection(items: [song])
        }
        self.musicPlayer.prepareToPlay { [unowned self] error in
            guard error == nil else {
                debugPrint(error ?? "")
                return
            }
            self.play()
        }
    }
    
    func play() {
        if self.musicPlayer.isPreparedToPlay {
            self.musicPlayer.play()
        } else {
            if let nowPlayItem = self.musicPlayer.nowPlayingItem {
                self.queue = MPMediaItemCollection(items: [nowPlayItem])
            }
            self.musicPlayer.prepareToPlay { error in
                guard error == nil else {
                    debugPrint(error ?? "")
                    return
                }
                self.play()
            }
        }
    }
    
    func pause() {
        self.musicPlayer.pause()
    }
    
    func next() {
        self.musicPlayer.skipToNextItem()
    }
    
    func previous() {
        self.musicPlayer.skipToPreviousItem()
    }
    
    // MARK: - Search
    func searh(for query: String, completion: @escaping ([Song], [Album], [Artist]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            let songsQuery = MPMediaQuery.songs()
            songsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: query,
                                                                   forProperty: MPMediaItemPropertyTitle,
                                                                   comparisonType: .contains))
            
            let albumsQuery = MPMediaQuery.albums()
            albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: query,
                                                                   forProperty: MPMediaItemPropertyAlbumTitle,
                                                                   comparisonType: .contains))
            
            let artistQuery = MPMediaQuery.artists()
            artistQuery.addFilterPredicate(MPMediaPropertyPredicate(value: query,
                                                                    forProperty: MPMediaItemPropertyArtist,
                                                                    comparisonType: .contains))
            
            DispatchQueue.main.async {
                completion(songsQuery.items ?? [], albumsQuery.collections ?? [], artistQuery.collections ?? [])
            }
        }
    }

}

extension MediaLibraryHelper.Playlist {
    
    var isFolder: Bool {
        return (self.value(forProperty: "isFolder") as? Bool) ?? false
    }
    
    var parentPersistentID: MPMediaEntityPersistentID? {
        return self.value(forProperty: "parentPersistentID") as? MPMediaEntityPersistentID
    }
    
}

extension MediaLibraryHelper.PlaylistFolder {
    
    var name: String {
        return (self.value(forProperty: MPMediaPlaylistPropertyName) as? String) ?? "Unknown Playlist"
    }
    
}
