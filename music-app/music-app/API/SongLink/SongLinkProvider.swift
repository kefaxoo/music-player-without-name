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
                    guard let link = try? response.mapObject(ShareLinkModel.self) else { return }
                    
                    success(link.link)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    func recognizeLink(_ url: String, success: @escaping((Int) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.recognizeLink(url)) { result in
            switch result {
                case .success(let response):
                    guard let id = try? response.mapObject(IDModel.self) else { return }
                    
                    success(id.deezerID)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
}
