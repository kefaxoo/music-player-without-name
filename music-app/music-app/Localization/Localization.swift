//
//  Localization.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 17.02.23.
//

import Foundation

enum Localization {}

extension Localization {
    enum Library: String {
        case playslists = "library.playlists"
        case artists    = "library.artists"
        case albums     = "library.albums"
        case songs      = "library.songs"
        case downloaded = "library.downloaded"
    }
    
    enum MenuActions: String {
        case addToLibrary = "menuActions.addToLibrary"
        case removeFromLibrary = "menuActions.removeFromLibrary"
        case shareSong = "menuActions.shareSong"
        case shareLink = "menuActions.shareLink"
        case removePlaylistFromLibrary = "menuActions.removePlaylistFromLibrary"
        case showAlbum = "menuActions.showAlbum"
    }
    
    enum TabBar: String {
        case search = "tabBar.search"
        case library = "tabBar.library"
    }
    
    enum Alert {}
    
    enum Controller {}
    
    enum SearchBarPlaceholder: String {
        case tracks = "searchBarPlaceholder.tracks"
        case albums = "searchBarPlaceholder.albums"
        case artists = "searchBarPlaceholder.artists"
        case playlists = "searchBarPlaceholder.playlists"
        case main = "searchBarPlaceholder.main"
    }
}

extension Localization.MenuActions {
    enum ShareLink: String {
        case shareMessage = "menuActions.shareLink.shareSong"
    }
}

extension Localization.Alert {
    enum Title: String {
        case error = "alert.title.error"
        case success = "alert.title.success"
        case loadingArtists = "alert.title.loadingArtists"
        case loadingAlbums = "alert.title.loadingAlbums"
    }
    
    enum Message: String {
        case errorPlaylist = "alert.message.errorPlaylist"
    }
}

extension Localization.Controller {
    enum AddPlaylist: String {
        case cancel = "controller.addPlaylist.cancel"
        case done = "controller.addPlaylist.done"
        case textFieldPlaceholder = "controller.addPlaylist.textFieldPlaceholder"
        case addTracks = "controller.addPlaylist.addTracks"
        case title = "controller.addPlaylist.title"
    }
    
    enum Search {}
    
    enum Library: String {
        case recentlyAddedLabel = "controller.library.recentlyAddedLabel"
    }
    
    enum Album {}
    
    enum Artist {}
}

extension Localization.Controller.Search {
    enum segmentedControl: String {
        case tracks = "controller.search.segmentedControl.tracks"
        case artists = "controller.search.segmentedControl.artists"
        case albums = "controller.search.segmentedControl.albums"
    }
}

extension Localization.Controller.Library {
    enum Playlists: String {
        case navBarButton = "controller.library.playlists.addPlaylist"
    }
}

extension Localization.Controller.Album {
    enum AlbumInfoCell: String {
        case playButton = "controller.album.albumInfoCell.playButton"
        case shuffleButton = "controller.album.albumInfoCell.shuffleButton"
    }
    
    enum MoreAlbumsByArtistCell: String {
        case moreByButton = "controller.album.moreAlbumsCell.moreByButton"
    }
}

extension Localization.Controller.Artist {
    enum TopTrackLabelCell: String {
        case title = "controller.artist.topTrackLabelCell.title"
    }
    
    enum MoreAlbumsByArtistCell: String {
        case title = "controller.artist.moreAlbumsCell.moreByButton"
    }
}
