//
//  LibraryTrack.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.02.23.
//

import Foundation
import RealmSwift

final class LibraryTrack: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var duration = 0
    @objc dynamic var trackPosition = 0
    @objc dynamic var diskNumber = 0
    @objc dynamic var isExplicit = false
    @objc dynamic var artistID = 0
    @objc dynamic var albumID = 0
    @objc dynamic var pathLink = ""
    
    convenience init(id: Int = 0, title: String = "", duration: Int = 0, trackPosition: Int = 0, diskNumber: Int = 0, isExplicit: Bool = false, artistID: Int = 0, albumID: Int = 0) {
        self.init()
        self.id = id
        self.title = title
        self.duration = duration
        self.trackPosition = trackPosition
        self.diskNumber = diskNumber
        self.isExplicit = isExplicit
        self.artistID = artistID
        self.albumID = albumID
    }
    
}
