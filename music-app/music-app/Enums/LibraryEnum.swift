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
    case download
    
    var icon: UIImage? {
        switch self {
            case .playlists:
                return UIImage(systemName: "music.note.list")
            case .artists:
                return UIImage(systemName: "music.mic")
            case .albums:
                return UIImage(systemName: "play.square")
            case .songs:
                return UIImage(systemName: "music.quarternote.3")
            case .download:
                return UIImage(systemName: "square.and.arrow.down")
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
            case .download:
                return Localization.Library.download.rawValue.localized
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
            case .download:
                return LibrarySongsController()
        }
    }
}
