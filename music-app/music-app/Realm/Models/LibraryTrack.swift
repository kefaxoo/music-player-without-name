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
    
    convenience init(id: Int, title: String, duration: Int, trackPosition: Int, diskNumber: Int, isExplicit: Bool, artistID: Int, artistName: String = "", albumID: Int, albumName: String = "", onlineLink: String, cacheLink: String, coverLink: String = "") {
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
    
}
