//
//  SearchBarEnum.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 17.02.23.
//

import Foundation

enum SearchBarEnum {
    case tracks
    case albums
    case artists
    case playlists
    case main
    
    var title: String {
        switch self {
            case .tracks:
                return Localization.SearchBarPlaceholder.tracks.rawValue.localized
            case .albums:
                return Localization.SearchBarPlaceholder.albums.rawValue.localized
            case .artists:
                return Localization.SearchBarPlaceholder.artists.rawValue.localized
            case .playlists:
                return Localization.SearchBarPlaceholder.playlists.rawValue.localized
            case .main:
                return Localization.SearchBarPlaceholder.main.rawValue.localized
        }
    }
}
