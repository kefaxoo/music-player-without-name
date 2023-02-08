//
//  DeezerArtist.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.01.23.
//

import Foundation
import ObjectMapper

final class DeezerArtist: Mappable {
    var id = 0
    var name = ""
    var pictureSmall: String?
    var pictureBig: String?
    var numberOfAlbums: Int?
    var numberOfFans: Int?
    private var isRadioAvailablePrivate: Int?
    lazy var isRadioAvailable: Bool = {
        guard let isRadioAvailablePrivate else { return false }
        
        return Bool(truncating: isRadioAvailablePrivate as NSNumber)
    }()
    
    var position: Int?
    var type = ""
    
    init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        id               <- map["id"]
        name             <- map["name"]
        pictureSmall     <- map["picture_small"]
        pictureBig       <- map["picture_xl"]
        numberOfAlbums   <- map["nb_album"]
        numberOfFans     <- map["nb_fans"]
        isRadioAvailable <- map["radio"]
        position         <- map["position"]
        type             <- map["type"]
    }
}
