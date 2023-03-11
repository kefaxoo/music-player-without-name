//
//  SpotifyAPI.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 9.03.23.
//

import Foundation
import Moya

enum SpotifyAPI {
    case getCanvasLink(_ id: String)
}

extension SpotifyAPI: TargetType {
    var baseURL: URL {
        switch self {
            case .getCanvasLink(_):
                return URL(string: "https://api.delitefully.com/api")!
        }
    }
    
    var path: String {
        switch self {
            case .getCanvasLink(let id):
                return "/canvas/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getCanvasLink(_):
                return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Moya.Task {
        guard let parameters else { return .requestPlain }
        
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        switch self {
            case .getCanvasLink(_):
                return nil
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
            case .getCanvasLink(_):
                return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
            case .getCanvasLink(_):
                return URLEncoding.queryString
        }
    }
}
