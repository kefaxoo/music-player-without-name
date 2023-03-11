//
//  SpotifyProvider.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 9.03.23.
//

import Foundation
import Moya
import Moya_ObjectMapper

final class SpotifyProvider {
    private let provider = MoyaProvider<SpotifyAPI>(plugins: [NetworkLoggerPlugin()])
    
    func getCanvasLink(_ id: String, success: @escaping((String) -> Void), failure: ((String) -> Void)? = nil) {
        provider.request(.getCanvasLink(id)) { result in
            switch result {
                case .success(let response):
                    guard let canvasObject = try? response.mapObject(CanvasModel.self),
                          let canvasLink = canvasObject.canvasLink
                    else { return success("") }
                    
                    success(canvasLink)
                case .failure(_):
                    break
            }
        }
    }
}
