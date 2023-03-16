//
//  LibraryTrack.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.02.23.
//

import Foundation
import RealmSwift

class LibraryTrack: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var duration = 0
    @objc dynamic var trackPosition = 0
    @objc dynamic var diskNumber = 0
    @objc dynamic var isExplicit = false
    @objc dynamic var artistID = 0
    @objc dynamic var artistName = ""
    @objc dynamic var albumID = 0
    @objc dynamic var albumTitle = ""
    @objc dynamic var onlineLink = ""
    @objc dynamic var cacheLink = ""
    @objc dynamic var coverLink = ""
    
    convenience init(id: Int, title: String, duration: Int, trackPosition: Int, diskNumber: Int, isExplicit: Bool, artistID: Int, artistName: String, albumID: Int, albumName: String, onlineLink: String, cacheLink: String, coverLink: String) {
        self.init()
        self.id = id
        self.title = title
        self.duration = duration
        self.trackPosition = trackPosition
        self.diskNumber = diskNumber
        self.isExplicit = isExplicit
        self.artistID = artistID
        self.artistName = artistName
        self.albumID = albumID
        self.albumTitle = albumName
        self.onlineLink = onlineLink
        self.cacheLink = cacheLink
        self.coverLink = coverLink
    }
    
    static func getLibraryTrack(_ track: LibraryTrackInPlaylist) -> LibraryTrack {
        return LibraryTrack(id: track.id, title: track.title, duration: track.duration, trackPosition: track.trackPosition, diskNumber: track.diskNumber, isExplicit: track.isExplicit, artistID: track.artistID, artistName: track.artistName, albumID: track.albumID, albumName: track.albumTitle, onlineLink: track.onlineLink, cacheLink: track.cacheLink, coverLink: track.coverLink)
    }
    
    static func getLibraryTrack(_ track: DeezerTrack) -> LibraryTrack? {
        guard let artist = track.artist,
              let album = track.album
        else { return nil }
        
        let trackPosition = track.trackPosition ?? 0
        let diskNumber = track.diskNumber ?? 0
        
        var cacheLink = ""
        if LibraryManager.isTrackDownloaded(artist: artist.name, title: track.title, album: album.title) {
            cacheLink = "Music/\("\(artist.name) - \(track.title) - \(album.title)".toUnixFilename).mp3"
        }
        
        var coverLink = ""
        if LibraryManager.isCoverDownloaded(artist: artist.name, album: album.title) {
            coverLink = "Artworks/\("\(artist.name) - \(album.title).jpg".toUnixFilename)"
        }
        
        return LibraryTrack(id: track.id, title: track.title, duration: track.duration, trackPosition: trackPosition, diskNumber: diskNumber, isExplicit: track.isExplicit, artistID: artist.id, artistName: artist.name, albumID: album.id, albumName: album.title, onlineLink: track.downloadLink, cacheLink: cacheLink, coverLink: coverLink)
    }
}
