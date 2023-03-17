//
//  LinkModel.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 9.03.23.
//

import Foundation
import ObjectMapper

class LinkModel: Mappable {
    var deezerLink = ""
    var yandexMusicLink: String?
    var spotifyLink: String?
    var youtubeLink: String?
    var link = ""
    lazy var deezerID: Int? = {
        return Int(deezerLink.replacingOccurrences(of: "https://www.deezer.com/track/", with: ""))
    }()
    
    lazy var yandexMusicID: Int? = {
        guard let yandexMusicLink else { return nil }
        
        return Int(yandexMusicLink.replacingOccurrences(of: "https://music.yandex.ru/track/", with: ""))
    }()
    
    lazy var spotifyID: String? = {
        guard let spotifyLink else { return nil }
        
        return spotifyLink.replacingOccurrences(of: "https://open.spotify.com/track/", with: "")
    }()
    
    lazy var youtubeID: String? = {
        guard let youtubeLink else { return nil }
        
        return youtubeLink.replacingOccurrences(of: "https://music.youtube.com/watch?v=", with: "")
    }()
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        deezerLink      <- map["linksByPlatform.deezer.url"]
        yandexMusicLink <- map["linksByPlatform.yandex.url"]
        spotifyLink     <- map["linksByPlatform.spotify.url"]
        youtubeLink     <- map["linksByPlatform.youtubeMusic.url"]
        link            <- map["pageUrl"]
    }
}
