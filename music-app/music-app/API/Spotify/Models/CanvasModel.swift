//
//  CanvasModel.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 9.03.23.
//

import Foundation
import ObjectMapper

final class CanvasModel: Mappable {
    var success = ""
    var canvasLink: String?
    
    init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        success <- map["success"]
        canvasLink <- map["canvas_url"]
    }
    
    
}
