//
//  LibraryTrackInPlaylist.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 15.02.23.
//

import Foundation
import RealmSwift

class LibraryTrackInPlaylist: Object {
    @objc dynamic var id = 0
    @objc dynamic var playlistID = ""
    @objc dynamic var title = ""
    @objc dynamic var duration = 0
    @objc dynamic var trackPosition = 0
    @objc dynamic var isExplicit = false
    @objc dynamic var artistID = 0
    @objc dynamic var albumID = 0
    @objc dynamic var pathLink = ""
    
    convenience init(id: Int, playlistID: String, title: String, duration: Int, trackPosition: Int, isExplicit: Bool, artistID: Int, albumID: Int) {
        self.init()
        self.id = id
        self.playlistID = playlistID
        self.title = title
        self.duration = duration
        self.trackPosition = trackPosition
        self.isExplicit = isExplicit
        self.artistID = artistID
        self.albumID = albumID
        self.pathLink = pathLink
    }
}
