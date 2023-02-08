//
//  DeezerGenre.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.01.23.
//

import Foundation
import ObjectMapper

final class DeezerGenre: Mappable {
    var id = 0
    var name = ""
    var pictureSmall: String?
    var pictureBig: String?
    var type = ""
    
    init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        id           <- map["id"]
        name         <- map["name"]
        pictureSmall <- map["picture_small"]
        pictureBig   <- map["picture_xl"]
        type         <- map["type"]
    }
}
