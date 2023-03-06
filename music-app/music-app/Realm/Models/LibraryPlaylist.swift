//
//  LibraryPlaylist.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 15.02.23.
//

import Foundation
import RealmSwift

class LibraryPlaylist: Object {
    @objc dynamic var id = ""
    @objc dynamic var image = ""
    @objc dynamic var name = ""
    @objc dynamic var isExplicit = false
    
    convenience init(id: String, image: String, name: String, isExplicit: Bool) {
        self.init()
        self.id = id
        self.image = image
        self.name = name
        self.isExplicit = isExplicit
    }
    
    func updateIsExplicit() {
        var isExplicit = false
        RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == id }).forEach { track in
            if track.isExplicit {
                isExplicit = true
            }
        }
        
        RealmManager<LibraryPlaylist>().update { realm in
            try? realm.write {
                self.isExplicit = isExplicit
            }
        }
    }
    
    var duration: Int {
        var duration = 0
        RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == self.id }).forEach { track in
            duration += track.duration
        }
        
        return duration
    }
    
    var countOfTracks: Int {
        return RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == self.id }).count
    }
}
