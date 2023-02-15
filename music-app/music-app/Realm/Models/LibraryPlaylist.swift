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
}
