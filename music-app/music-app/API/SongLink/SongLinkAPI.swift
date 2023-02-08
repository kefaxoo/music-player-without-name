//
//  SongLinkAPI.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 26.01.23.
//

import Foundation
import Moya

enum SongLinkAPI {
    case getLink(_ url: String)
    case recognizeLink(_ url: String)
}

extension SongLinkAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.song.link/v1-alpha.1")!
    }
    
    var path: String {
        return "/links"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Moya.Task {
        guard let parameters else { return .requestPlain }
                
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var parameters: [String : Any]? {
        var params = [String:Any]()
        switch self {
            case .getLink(let url), .recognizeLink(let url):
                params["url"] = url
                params["key"] = "9ab8abaf-c5f1-4edb-8e7f-7f72c7033693"
        }
        
        return params
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.queryString
    }
}
