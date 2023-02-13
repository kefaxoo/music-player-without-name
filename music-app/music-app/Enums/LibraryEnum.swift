//
//  LibraryEnum.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.02.23.
//

import UIKit

enum LibraryEnum: CaseIterable {
    case playlists
    case artists
    case albums
    case songs
    case downloaded
    
    var icon: String {
        switch self {
            case .playlists:
                return "music.note.list"
            case .artists:
                return "music.mic"
            case .albums:
                return "play.square"
            case .songs:
                return "music.quarternote.3"
            case .downloaded:
                return "square.and.arrow.down"
        }
    }
    
    var name: String {
        switch self {
            case .playlists:
                return "Playlists"
            case .artists:
                return "Artists"
            case .albums:
                return "Albums"
            case .songs:
                return "Songs"
            case .downloaded:
                return "Downloaded"
        }
    }
    
    var vc: UIViewController {
        switch self {
            case .playlists:
                return LibrarySongsController()
            case .artists:
                return LibraryArtistsController()
            case .albums:
                return LibraryAlbumsController()
            case .songs:
                return LibrarySongsController()
            case .downloaded:
                return LibrarySongsController()
        }
    }
}
