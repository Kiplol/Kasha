//
//  MediaLibraryHelper.swift
//  Kasha
//
//  Created by Elliott Kipper on 6/10/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Gestalt
import Hue
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
    var isShuffleOn: Bool {
        return self.musicPlayer.shuffleMode != .off
    }
    
    // MARK: - Initializers
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(MediaLibraryHelper.nowPlayingItemDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        if let nowPlayingItem = self.musicPlayer.nowPlayingItem {
            self.makeTheme(fromNowPlayingItem: nowPlayingItem)
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
    
    func allAlbums(inSection section: MPMediaQuerySection) -> [Album] {
        let allAlbums = self.allAlbums()
        var albumsInThisSection: [Album] = []
        for i in stride(from: section.range.location, to: section.range.location + section.range.length, by: 1) {
            albumsInThisSection.append(allAlbums[i])
        }
        return albumsInThisSection
    }
    
    func albums(forArtist artist: Artist) -> [Album] {
        let artistID = artist.persistentID
        let albumsQuery = MPMediaQuery.albums()
        albumsQuery.addFilterPredicate(MPMediaPropertyPredicate(value: artistID,
                                                                forProperty: MPMediaItemPropertyArtistPersistentID))
        return albumsQuery.collections?.filter { $0.albumNameIfNotEmpty != nil } ?? []
    }
    
    func recentlyAddedAlbums() -> [Album] {
        let ninetyDaysAgo = Date().timeIntervalSince1970 - 60.0 * 60.0 * 24.0 * 90.0
        var recentAlbums: [Album] = []
        let albums = self.allAlbums()//.filter { !$0.items.isEmpty && $0.items[0].dateAdded.timeIntervalSince1970 > thirtyDaysAgo }
        DispatchQueue.concurrentPerform(iterations: albums.count) { index in
            let album = albums[index]
            guard let representativeItem = album.representativeItem else {
                return
            }
            if representativeItem.dateAdded.timeIntervalSince1970 > ninetyDaysAgo {
                recentAlbums.append(album)
            }
        }
        return recentAlbums.sorted(by: { album1, album2 -> Bool in
            guard let representativeItem1 = album1.representativeItem,
                let representativeItem2 = album2.representativeItem else {
                    if album1.representativeItem != nil {
                        return true
                    } else {
                        return false
                    }
            }
            return representativeItem1.dateAdded.timeIntervalSince1970 > representativeItem2.dateAdded.timeIntervalSince1970
        })
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
    
    func allSongsForUnknownAlbum(forArtist artist: MPMediaItemCollection) -> [Song] {
        let artistID = artist.persistentID
        let albumName = ""
        let songQuery = MPMediaQuery.songs()
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: artistID, forProperty: MPMediaItemPropertyArtistPersistentID))
        songQuery.addFilterPredicate(MPMediaPropertyPredicate(value: albumName,
                                                              forProperty: MPMediaItemPropertyAlbumTitle))
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
    
    func toggleShuffle() -> Bool {
        switch self.musicPlayer.shuffleMode {
        case .off:
            self.turnOnShuffle()
            return true
        default:
            self.tunOffShuffle()
            return false
        }
    }
    
    func turnOnShuffle() {
        self.musicPlayer.shuffleMode = .songs
    }
    
    func tunOffShuffle() {
        self.musicPlayer.shuffleMode = .off
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
            
            let playlistQuery = MPMediaQuery.playlists()
            playlistQuery.addFilterPredicate(MPMediaPropertyPredicate(value: query,
                                                                      forProperty: MPMediaPlaylistPropertyName,
                                                                      comparisonType: .contains))
            let playlists = (playlistQuery.collections ?? []).filter { $0.count > 0 }
            
            DispatchQueue.main.async {
                completion(songsQuery.items ?? [], albumsQuery.collections ?? [], artistQuery.collections ?? [])
            }
        }
    }
    
    // MARK: - Media Notifications
    @objc func nowPlayingItemDidChange(_ notif: Notification) {
        guard let nowPlayingItem = (notif.object as? MPMusicPlayerController)?.nowPlayingItem else {
            ThemeManager.default.theme = Theme.light
            return
        }
        
        self.makeTheme(fromNowPlayingItem: nowPlayingItem)
    }
    
    private func makeTheme(fromNowPlayingItem nowPlayingItem: MPMediaItem) {
        DispatchQueue.global(qos: .default).async {
            guard let image = nowPlayingItem.artwork?.image(at: CGSize(width: 54.0, height: 54.0)) else {
                DispatchQueue.main.async {
                    ThemeManager.default.theme = Theme.light
                }
                return
            }
            let (background, primary, secondary, detail) = image.colors()
            let newPlayerTheme = Theme.PlayerTheme(playerBackgroundColor: background, playerPrimaryColor: primary,
                                 playerSecondaryColor: secondary, playerDetailColor: detail)
            let newTheme = (ThemeManager.default.theme as? Theme ?? Theme.light).copy(withPlayerTheme: newPlayerTheme)
            ThemeManager.default.theme = newTheme
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

extension MediaLibraryHelper.Album {
    var albumNameIfNotEmpty: String? {
        guard let albumName = self.representativeItem?.albumTitle, !albumName.isEmpty else {
            return nil
        }
        return albumName
    }
}
