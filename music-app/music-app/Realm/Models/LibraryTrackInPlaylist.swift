//
//  LibraryTrackInPlaylist.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 15.02.23.
//

import Foundation
import RealmSwift

class LibraryTrackInPlaylist: LibraryTrack {
    @objc dynamic var playlistID = ""
    
    convenience init(id: Int, title: String, duration: Int, trackPosition: Int, diskNumber: Int, isExplicit: Bool, artistID: Int, artistName: String, albumID: Int, albumName: String, onlineLink: String, cacheLink: String, coverLink: String, playlistID: String) {
        self.init(id: id, title: title, duration: duration, trackPosition: trackPosition, diskNumber: diskNumber, isExplicit: isExplicit, artistID: artistID, artistName: artistName, albumID: albumID, albumName: albumName, onlineLink: onlineLink, cacheLink: cacheLink, coverLink: coverLink)
        self.playlistID = playlistID
    }
    
    var libraryTrack: LibraryTrack {
        return LibraryTrack(id: self.id, title: self.title, duration: self.duration, trackPosition: self.trackPosition, diskNumber: self.diskNumber, isExplicit: self.isExplicit, artistID: self.artistID, artistName: self.artistName, albumID: self.albumID, albumName: self.albumTitle, onlineLink: self.onlineLink, cacheLink: self.cacheLink, coverLink: self.coverLink)
    }
}
