//
//  DeezerProvider.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.01.23.
//

import Foundation
import Moya
import Moya_ObjectMapper
import Alamofire

final class DeezerProvider {
    private static let provider = MoyaProvider<DeezerAPI>(plugins: [NetworkLoggerPlugin()])
    
    static func getAlbum(_ id: Int, success: @escaping((DeezerAlbum) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.getAlbum(id)) { result in
            switch result {
                case .success(let response):
                    guard let album = try? response.mapObject(DeezerAlbum.self) else { return }
                    
                    success(album)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    static func getArtist(_ id: Int, success: @escaping((DeezerArtist) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.getArtist(id)) { result in
            switch result {
                case .success(let response):
                    guard let artist = try? response.mapObject(DeezerArtist.self) else { return }
                    
                    success(artist)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    static func getTopTracks(success: @escaping(([DeezerTrack]) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.getTopTracks) { result in
            switch result {
                case .success(let response):
                    guard let data = try? response.mapObject(DeezerData<DeezerTrack>.self) else { return }
                    
                    success(data.data)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    static func getTopAlbums(success: @escaping(([DeezerAlbum]) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.getTopAlbums) { result in
            switch result {
                case .success(let response):
                    guard let data = try? response.mapObject(DeezerData<DeezerAlbum>.self) else { return }
                    
                    success(data.data)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    static func getTopArtists(success: @escaping(([DeezerArtist]) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.getTopArtist) { result in
            switch result {
                case .success(let response):
                    guard let data = try? response.mapObject(DeezerData<DeezerArtist>.self) else { return }
                    
                    success(data.data)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    static func getGenre(_ id: Int, success: @escaping((DeezerGenre) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.getGenre(id)) { result in
            switch result {
                case .success(let response):
                    guard let genre = try? response.mapObject(DeezerGenre.self) else { return }
                    
                    success(genre)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    static func findTracks(queryParameter: String, success: @escaping(([DeezerTrack]) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.find(queryParameter: queryParameter, type: .track)) { result in
            switch result {
                case .success(let response):
                    guard let tracks = try? response.mapObject(DeezerData<DeezerTrack>.self) else { return }
                    
                    success(tracks.data)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    static func findAlbums(queryParameter: String, success: @escaping(([DeezerAlbum]) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.find(queryParameter: queryParameter, type: .album)) { result in
            switch result {
                case .success(let response):
                    guard let albums = try? response.mapObject(DeezerData<DeezerAlbum>.self) else { return }
                    
                    success(albums.data)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    static func findArtists(queryParameter: String, success: @escaping(([DeezerArtist]) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.find(queryParameter: queryParameter, type: .artist)) { result in
            switch result {
                case .success(let response):
                    guard let artists = try? response.mapObject(DeezerData<DeezerArtist>.self) else { return }
                    
                    success(artists.data)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
    
    static func getTrack(_ id: Int, success: @escaping((DeezerTrack) -> Void), failure: @escaping((String) -> Void)) {
        provider.request(.getTrack(id)) { result in
            switch result {
                case .success(let response):
                    guard let track = try? response.mapObject(DeezerTrack.self) else { return }
                    
                    success(track)
                case .failure(let error):
                    guard let description = error.errorDescription else { return }
                    
                    failure(description)
            }
        }
    }
}
