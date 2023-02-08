//
//  DeezerData.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.01.23.
//

import Foundation
import ObjectMapper

final class DeezerData<T>: Mappable where T: Mappable {
    var data = [T]()
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        data <- map["data"]
    }
}
