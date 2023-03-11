//
//  SongLinkProvider.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 26.01.23.
//

import Foundation
import Moya
import Moya_ObjectMapper

final class SongLinkProvider {
    private let provider = MoyaProvider<SongLinkAPI>(plugins: [NetworkLoggerPlugin()])
    
    func getShareLink(_ url: String, success: @escaping((String) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.getLink(url)) { result in
            switch result {
                case .success(let response):
                    guard let links = try? response.mapObject(LinkModel.self) else { return }
                    
                    success(links.link)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    func getSpotifyID(_ url: String, success: @escaping((String) -> Void), failure: ((String) -> Void)? = nil) {
        provider.request(.getLink(url)) { result in
            switch result {
                case .success(let response):
                    guard let links = try? response.mapObject(LinkModel.self),
                          let spotifyID = links.spotifyID else { return }
                    
                    success(spotifyID)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func getYandexMusicID(_ url: String, success: @escaping((Int) -> Void), failure: ((String) -> Void)?) {
        provider.request(.getLink(url)) { result in
            switch result {
                case .success(let response):
                    guard let links = try? response.mapObject(LinkModel.self),
                          let yandexMusicID = links.yandexMusicID
                    else { return }
                    
                    success(yandexMusicID)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func getLinks(_ url: String, success: @escaping((LinkModel) -> Void), failure: ((String) -> Void)? = nil) {
        provider.request(.getLink(url)) { result in
            switch result {
                case .success(let response):
                    guard let links = try? response.mapObject(LinkModel.self) else { return }
                    
                    success(links)
                case .failure(_):
                    break
            }
        }
    }
}
