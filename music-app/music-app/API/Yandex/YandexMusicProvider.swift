//
//  YandexMusicProvider.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 10.03.23.
//

import Foundation
import Moya
import Moya_ObjectMapper

final class YandexMusicProvider {
    private let provider = MoyaProvider<YandexMusicAPI>(plugins: [NetworkLoggerPlugin()])
    
    func getCanvasLink(_ id: Int, success: @escaping((String) -> Void), failure: ((String) -> Void)? = nil) {
        provider.request(.getCanvasLink(id)) { result in
            switch result {
                case .success(let response):
                    guard let results = try? response.mapObject(ymresult.self),
                          let track = results.results.first,
                          let canvasLink = track.canvasLink else { return }
                    
                    success(canvasLink)
                case .failure(let error):
                    print(error)
            }
        }
    }
}
