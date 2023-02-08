//
//  DeezerAlbum.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.01.23.
//

import Foundation
import ObjectMapper

class DeezerAlbum: Mappable {
    var id = 0
    var title = ""
    var coverSmall = ""
    var coverBig = ""
    var genreID: Int?
    var genres: DeezerData<DeezerGenre>?
    var label: String?
    var numberOfTracks: Int?
    var duration: Int?
    var countOfFans: Int?
    var releaseDate: String?
    var recordType: String?
    private var isExplicitPrivate: Int?
    lazy var isExplicit: Bool = {
        guard let isExplicitPrivate else { return false }
        
        return Bool(truncating: isExplicitPrivate as NSNumber)
    }()
    
    var position: Int?
    var contributors: [DeezerArtist]?
    var artist: DeezerArtist?
    var type: String?
    var tracks: DeezerData<DeezerTrack>?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id                <- map["id"]
        title             <- map["title"]
        coverSmall        <- map["cover_medium"]
        coverBig          <- map["cover_xl"]
        genreID           <- map["genre_id"]
        genres            <- map["genres"]
        label             <- map["label"]
        numberOfTracks    <- map["nb_tracks"]
        duration          <- map["duration"]
        countOfFans       <- map["fans"]
        releaseDate       <- map["release_date"]
        recordType        <- map["record_type"]
        isExplicitPrivate <- map["explicit_lyrics"]
        position          <- map["position"]
        contributors      <- map["contributors"]
        artist            <- map["artist"]
        type              <- map["type"]
        tracks            <- map["tracks"]
    }
}
