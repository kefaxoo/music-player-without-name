//
//  DeezerTrack.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.01.23.
//

import Foundation
import ObjectMapper

class DeezerTrack: Mappable {
    
    var id = 0
    var title = ""
    var duration = 0
    var trackPosition: Int?
    var diskNumber: Int?
    var releaseDate: String?
    private var isExplicitPrivate = 0
    lazy var isExplicit: Bool = {
        return Bool(truncating: isExplicitPrivate as NSNumber)
    }()
    
    var contributors: [DeezerArtist]?
    var position: Int?
    var artist: DeezerArtist?
    var album: DeezerAlbum?
    var type = ""
    
    lazy var downloadLink: String = {
        return "https://dz.loaderapp.info/deezer/128/https://deezer.com/track/\(id)"
    }()
    
    lazy var shareLink: String = {
        return "https://deezer.com/track/\(id)"
    }()
    
    var localLink: String = ""
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id            <- map["id"]
        title         <- map["title"]
        duration      <- map["duration"]
        trackPosition <- map["track_position"]
        diskNumber    <- map["disk_number"]
        releaseDate   <- map["release_date"]
        isExplicit    <- map["explicit_lyrics"]
        contributors  <- map["contributors"]
        position      <- map["position"]
        artist        <- map["artist"]
        album         <- map["album"]
        type          <- map["type"]
    }
}
