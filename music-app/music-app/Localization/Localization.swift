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
        case download = "library.download"
    }
    
    enum MenuActions: String {
        case addToLibrary = "menuActions.addToLibrary"
        case removeFromLibrary = "menuActions.removeFromLibrary"
        case shareSong = "menuActions.shareSong"
        case shareLink = "menuActions.shareLink"
        case removePlaylistFromLibrary = "menuActions.removePlaylistFromLibrary"
        case showAlbum = "menuActions.showAlbum"
        case download = "menuActions.download"
        case deleteDownload = "menuActions.deleteDownload"
        case showArtist = "menuActions.showArtist"
        case addToPlaylist = "menuActions.addToPlaylist"
    }
    
    enum TabBar: String {
        case search = "tabBar.search"
        case library = "tabBar.library"
        case settings = "tabBar.settings"
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
    
    enum Settings {}
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
        case trackInPlaylist = "alert.title.trackInPlaylist"
    }
    
    enum Message: String {
        case errorPlaylist = "alert.message.errorPlaylist"
        case errorDownload = "alert.message.errorDownload"
        case trackInPlaylist = "alert.message.trackInPlaylist"
    }
    
    enum Action: String {
        case addAnyway = "alert.action.addAnyway"
        case skipAdding = "alert.action.skipAdding"
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
        case desctiptionEmpty = "controller.library.playlists.description"
    }
    
    enum Songs {}
    
    enum AddToPlaylist: String {
        case title = "controller.library.addToPlaylist.title"
        case cancelButton = "controller.library.addToPlaylist.cancelButton"
    }
    
    enum Playlist {}
}

extension Localization.Controller.Library.Songs {
    enum SortButton: String {
        case title = "controller.library.songs.sortButton.title"
        case alphabet = "controller.library.songs.sortButton.alphabet"
        case reversedAlphabet = "controller.library.songs.sortButton.reversedAlphabet"
        case recentlyAdded = "controller.library.songs.sortButton.recentlyAdded"
    }
}

extension Localization.Controller.Library.Playlist {
    enum PlaylistInfoCell: String {
        case playButton = "controller.library.playlist.playlistInfoCell.playButton"
        case shuffleButton = "controller.library.playlist.playlistInfoCell.shuffleButton"
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

extension Localization.Settings {
    enum Color: String {
        case title = "settings.color.title"
        case blue = "settings.color.blue"
        case cyan = "settings.color.cyan"
        case green = "settings.color.green"
        case indigo = "settings.color.indigo"
        case mint = "settings.color.mint"
        case orange = "settings.color.orange"
        case pink = "settings.color.pink"
        case purple = "settings.color.purple"
        case red = "settings.color.red"
        case teal = "settings.color.teal"
        case yellow = "settings.color.yellow"
    }
}
