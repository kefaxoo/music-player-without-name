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
                return Localization.Library.playslists.rawValue.localized
            case .artists:
                return Localization.Library.artists.rawValue.localized
            case .albums:
                return Localization.Library.albums.rawValue.localized
            case .songs:
                return Localization.Library.songs.rawValue.localized
            case .downloaded:
                return Localization.Library.downloaded.rawValue.localized
        }
    }
    
    var vc: UIViewController {
        switch self {
            case .playlists:
                return LibraryPlaylistsController()
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
