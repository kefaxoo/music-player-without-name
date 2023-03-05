//
//  MenuActionsEnum.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import UIKit

enum MenuActionsEnum {
    case addToLibrary
    case removeFromLibrary
    case shareSong
    case shareLink
    case removePlaylistFromLibrary
    case showAlbum
    case download
    case deleteDownload
    case showArtist
    
    var image: UIImage? {
        switch self {
            case .addToLibrary:
                return UIImage(systemName: "heart")
            case .removeFromLibrary:
                return UIImage(systemName: "heart.slash.fill")
            case .shareSong:
                return UIImage(systemName: "music.note")
            case .shareLink:
                return UIImage(systemName: "square.and.arrow.up")
            case .removePlaylistFromLibrary, .deleteDownload:
                return UIImage(systemName: "trash.fill")
            case .showAlbum:
                return UIImage(systemName: "play.square")
            case .download:
                return UIImage(systemName: "square.and.arrow.down.fill")
            case .showArtist:
                return LibraryEnum.artists.icon
        }
    }
    
    var title: String {
        switch self {
            case .addToLibrary:
                return Localization.MenuActions.addToLibrary.rawValue.localized
            case .removeFromLibrary:
                return Localization.MenuActions.removeFromLibrary.rawValue.localized
            case .shareSong:
                return Localization.MenuActions.shareSong.rawValue.localized
            case .shareLink:
                return Localization.MenuActions.shareLink.rawValue.localized
            case .removePlaylistFromLibrary:
                return Localization.MenuActions.removePlaylistFromLibrary.rawValue.localized
            case .showAlbum:
                return Localization.MenuActions.showAlbum.rawValue.localized
            case .download:
                return Localization.MenuActions.download.rawValue.localized
            case .deleteDownload:
                return Localization.MenuActions.deleteDownload.rawValue.localized
            case .showArtist:
                return Localization.MenuActions.showArtist.rawValue.localized
        }
    }
}
