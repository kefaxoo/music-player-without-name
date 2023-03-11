//
//  YandexMusicAPI.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 10.03.23.
//

import Foundation
import Moya

enum YandexMusicAPI {
    case getCanvasLink(_ id: Int)
}

extension YandexMusicAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.music.yandex.net:443")!
    }
    
    var path: String {
        switch self {
            case .getCanvasLink(let id):
                return "/tracks/\(id)"
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
