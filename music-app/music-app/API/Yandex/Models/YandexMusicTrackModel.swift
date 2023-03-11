//
//  YandexMusicTrackModel.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 10.03.23.
//

import Foundation
import ObjectMapper

final class ymresult: Mappable {
    var results = [YandexMusicTrackModel]()
    
    init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        results <- map["result"]
    }
}

final class YandexMusicTrackModel: Mappable {
    var canvasLink: String?
    
    init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        canvasLink <- map["backgroundVideoUri"]
    }
}
