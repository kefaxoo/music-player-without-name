//
//  DeezerAPI.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.01.23.
//

import Foundation
import Moya

enum DeezerAPI {
    case getAlbum(_ id: Int)
    case getArtist(_ id: Int)
    case getTopTracks
    case getTopAlbums
    case getTopArtist
    case getGenre(_ id: Int)
    case find(queryParameter: String, type: DeezerType)
    case getTrack(_ id: Int)
}

extension DeezerAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.deezer.com")!
    }
    
    var path: String {
        switch self {
            case .getAlbum(let id):
                return "/album/\(id)"
            case .getArtist(let id):
                return "/artist/\(id)"
            case .getTopTracks:
                return "/chart/0/tracks"
            case .getTopAlbums:
                return "/chart/0/albums"
            case .getTopArtist:
                return "/chart/0/artists"
            case .getGenre(let id):
                return "/genre/\(id)"
            case .find(_, let type):
                var path = "/search"
                switch type {
                    case .album:
                        path.append("/album")
                    case .artist:
                        path.append("/artist")
                    case .track:
                        path.append("/track")
                }
                
                return path
            case .getTrack(let id):
                return "/track/\(id)"
        }
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
            case .find(let queryParameter, _):
                params["q"] = queryParameter
            default:
                return nil
        }
        return params
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.queryString
    }
}
