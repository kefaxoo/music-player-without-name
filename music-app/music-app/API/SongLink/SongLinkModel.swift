//
//  SongLinkModel.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 26.01.23.
//

import Foundation
import ObjectMapper

class ShareLinkModel: Mappable {
    var link = ""
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        link <- map["pageUrl"]
    }
}

class IDModel: Mappable {
    var deezerLink = ""
    lazy var deezerID: Int = {
        guard let id = Int(deezerLink.replacingOccurrences(of: "https://www.deezer.com/track/", with: "")) else { return 0}
        
        return id
    }()
    
    
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        deezerLink <- map["linksByPlatform.deezer.url"]
    }
}
