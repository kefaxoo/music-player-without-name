//
//  ActionsManager.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 3.03.23.
//

import UIKit
import SPAlert
import JDStatusBarNotification

final class ActionsManager {
    private enum ActionsEnum {
        case showArtist
        case showAlbum
        case removeTrackFromLibrary
        case shareSong
        case shareLink
        case downloadTrack
        case removeTrackFromCache
        case addToPlaylist
        case removePlaylistFromLibrary
        case likeTrack
        case removeTrackFromPlaylist
        
        enum ActionsWithoutImage {
            case addAnyway
            
            var title: String {
                switch self {
                    case .addAnyway:
                        return Localization.Alert.Action.addAnyway.rawValue.localized
                }
            }
        }
        
        var title: String {
            switch self {
                case .showArtist:
                    return Localization.MenuActions.showArtist.rawValue.localized
                case .showAlbum:
                    return Localization.MenuActions.showAlbum.rawValue.localized
                case .removeTrackFromLibrary:
                    return Localization.MenuActions.removeFromLibrary.rawValue.localized
                case .shareSong:
                    return Localization.MenuActions.shareSong.rawValue.localized
                case .shareLink:
                    return Localization.MenuActions.shareLink.rawValue.localized
                case .downloadTrack:
                    return Localization.MenuActions.download.rawValue.localized
                case .removeTrackFromCache:
                    return Localization.MenuActions.deleteDownload.rawValue.localized
                case .addToPlaylist:
                    return Localization.MenuActions.addToPlaylist.rawValue.localized
                case .removePlaylistFromLibrary:
                    return Localization.MenuActions.removePlaylistFromLibrary.rawValue.localized
                case .likeTrack:
                    return Localization.MenuActions.addToLibrary.rawValue.localized
                case .removeTrackFromPlaylist:
                    return Localization.MenuActions.removeTrackFromPlaylist.rawValue.localized
            }
        }
        
        var image: UIImage? {
            switch self {
                case .showArtist:
                    return UIImage(systemName: "music.mic")
                case .showAlbum:
                    return UIImage(systemName: "play.square")
                case .removeTrackFromLibrary:
                    return UIImage(systemName: "heart.slash.fill")
                case .shareSong, .shareLink:
                    return UIImage(systemName: "square.and.arrow.up")
                case .downloadTrack:
                    return UIImage(systemName: "arrow.down.circle.fill")
                case .removeTrackFromCache, .removePlaylistFromLibrary, .removeTrackFromPlaylist:
                    return UIImage(systemName: "trash.slash.fill")
                case .addToPlaylist:
                    return UIImage(systemName: "text.badge.plus")
                case .likeTrack:
                    return UIImage(systemName: "heart.fill")
                    
            }
        }
    }
    
    enum ShareEnum: String  {
        case track = "track"
        case album = "album"
    }
    
    weak var delegate: MenuActionsDelegate?
    
    func showArtistAction(id: Int, name: String) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.showArtist
        let action = UIAction(title: type.title, subtitle: name, image: type.image) { _ in
            let alert = SPAlertView(title: "", preset: .spinner)
            alert.dismissByTap = false
            delegate.present(alert: alert, haptic: .none)
            DeezerProvider.getArtist(id) { artist in
                let artistVC = ArtistController()
                artistVC.set(artist)
                delegate.dismiss(alert)
                delegate.dismiss()
                delegate.pushViewController(artistVC)
            } failure: { error in
                delegate.dismiss(alert)
                let alert = SPAlertView(title: "", preset: .error)
                delegate.present(alert: alert, haptic: .error)
            }
        }
        
        return action
    }
    
    func showArtistAction(_ artistID: Int) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.showArtist
        let action = UIAction(title: type.title, image: type.image) { _ in
            let alert = SPAlertView(title: "", preset: .spinner)
            alert.dismissByTap = false
            delegate.present(alert: alert, haptic: .none)
            DeezerProvider.getArtist(artistID) { artist in
                let artistVC = ArtistController()
                artistVC.set(artist)
                delegate.dismiss(alert)
                delegate.pushViewController(artistVC)
            } failure: { error in
                delegate.dismiss(alert)
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                delegate.present(alert: alert, haptic: .error)
            }
            
        }
        
        return action
    }
    
    func showAlbumAction(_ album: DeezerAlbum) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.showAlbum
        let action = UIAction(title: type.title, subtitle: album.title, image: type.image) { _ in
            DeezerProvider.getAlbum(album.id) { album in
                let albumVC = AlbumController()
                albumVC.set(album)
                delegate.dismiss()
                delegate.pushViewController(albumVC)
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                delegate.present(alert: alert, haptic: .error)
            }
        }
        
        return action
    }
    
    func showAlbumAction(_ albumID: Int) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.showAlbum
        let action = UIAction(title: type.title, image: type.image) { _ in
            let alert = SPAlertView(title: "", preset: .spinner)
            alert.dismissByTap = false
            delegate.present(alert: alert, haptic: .none)
            DeezerProvider.getAlbum(albumID) { album in
                let albumVC = AlbumController()
                albumVC.set(album)
                delegate.dismiss(alert)
                delegate.pushViewController(albumVC)
            } failure: { error in
                delegate.dismiss(alert)
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                delegate.present(alert: alert, haptic: .error)
            }
            
        }
        
        return action
    }
    
    func showAlbumAction(id albumID: Int, title albumTitle: String) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.showAlbum
        let action = UIAction(title: type.title, subtitle: albumTitle, image: type.image) { _ in
            let alert = SPAlertView(title: "", preset: .spinner)
            alert.dismissByTap = false
            delegate.present(alert: alert, haptic: .none)
            DeezerProvider.getAlbum(albumID) { album in
                let albumVC = AlbumController()
                albumVC.set(album)
                delegate.dismiss(alert)
                delegate.pushViewController(albumVC)
            } failure: { error in
                delegate.dismiss(alert)
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                delegate.present(alert: alert, haptic: .error)
            }
            
        }
        
        return action
    }
    
    func removeFromLibrary(_ trackID: Int) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.removeTrackFromLibrary
        let action = UIAction(title: type.title, image: type.image, attributes: .destructive) { _ in
            if let removingTrack = RealmManager<LibraryTrack>().read().first(where: { $0.id == trackID }) {
                RealmManager<LibraryTrack>().delete(object: removingTrack)
                let alertView = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
                delegate.present(alert: alertView, haptic: .success)
                delegate.reloadData()
            } else {
                let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                delegate.present(alert: alertView, haptic: .error)
            }
        }
        
        return action
    }
    
    func shareSongAction(_ trackID: Int) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.shareSong
        let action = UIAction(title: type.title, image: type.image) { _ in
            let alertView = SPAlertView(title: "", preset: .spinner)
            alertView.dismissByTap = false
            delegate.present(alert: alertView, haptic: .none)
            DeezerProvider.getTrack(trackID) { track in
                guard let artist = track.artist?.name,
                      let album = track.album?.title
                else {
                    delegate.dismiss(alertView)
                    let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                    delegate.present(alert: alert, haptic: .error)
                    return
                }
                
                let trackFilename = "\(artist) - \(track.title) - \(album)".toUnixFilename
                if let directoryURL = LibraryManager.getAbsolutePath(filename: trackFilename, path: .cachesDirectory)?.appendingPathExtension("mp3"),
                   let trackURL = URL(string: track.downloadLink) {
                    URLSession.shared.downloadTask(with: trackURL) { tempFileURL, response, error in
                        if let tempDirectoryURL = tempFileURL {
                            do {
                                let trackData = try Data(contentsOf: tempDirectoryURL)
                                try trackData.write(to: directoryURL)
                                DispatchQueue.main.async {
                                    let activityVC = UIActivityViewController(activityItems: [directoryURL], applicationActivities: nil)
                                    delegate.dismiss(alertView)
                                    delegate.present(activityVC)
                                    activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                                        do {
                                            try FileManager.default.removeItem(at: directoryURL)
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            } catch {
                                delegate.dismiss(alertView)
                                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                                delegate.present(alert: alert, haptic: .error)
                            }
                        }
                    }.resume()
                } else {
                    delegate.dismiss()
                    let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                    delegate.present(alert: alert, haptic: .error)
                }
            } failure: { error in
                delegate.dismiss(alertView)
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                delegate.present(alert: alert, haptic: .error)
            }
        }
        
        return action
    }
    
    func shareLinkAction(id: Int, type: ShareEnum) -> UIAction? {
        guard let delegate else { return nil }
       
        if type == .track {
            let type = ActionsEnum.shareLink
            let action = UIAction(title: type.title, image: type.image) { _ in
                let alert = SPAlertView(title: "", preset: .spinner)
                alert.dismissByTap = false
                delegate.present(alert: alert, haptic: .none)
                DeezerProvider.getTrack(id) { track in
                    guard let artist = track.artist?.name else { return }
                    
                    SongLinkProvider().getShareLink(track.shareLink) { link in
                        let text = Localization.MenuActions.ShareLink.shareMessage.rawValue.localizedWithParameters(title: track.title, artist: artist, link: link)
                        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        delegate.dismiss(alert)
                        delegate.present(activityVC)
                    } failure: { error in
                        delegate.dismiss(alert)
                        let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                        delegate.present(alert: alert, haptic: .error)
                    }
                } failure: { error in
                    delegate.dismiss(alert)
                    let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                    delegate.present(alert: alert, haptic: .error)
                }
            }
            
            return action
        } else {
            let type = ActionsEnum.shareLink
            let action = UIAction(title: type.title, image: type.image) { _ in
                let alert = SPAlertView(title: "", preset: .spinner)
                alert.dismissByTap = false
                delegate.present(alert: alert, haptic: .none)
                DeezerProvider.getAlbum(id) { album in
                    guard let artist = album.artist?.name else { return }
                    
                    SongLinkProvider().getShareLink(album.shareLink) { link in
                        let text = Localization.MenuActions.ShareLink.shareMessage.rawValue.localizedWithParameters(title: album.title, artist: artist, link: link)
                        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        delegate.dismiss(alert)
                        delegate.present(activityVC)
                    } failure: { error in
                        delegate.dismiss(alert)
                        let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                        delegate.present(alert: alert, haptic: .error)
                    }
                } failure: { error in
                    delegate.dismiss(alert)
                    let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                    delegate.present(alert: alert, haptic: .error)
                }
            }
            
            return action
        }
    }
    
    func downloadTrackAction(track: LibraryTrack, completion: ((String) -> Void)? = nil) -> UIAction? {
        guard let delegate else { return nil }
        let type = ActionsEnum.downloadTrack
        let action = UIAction(title: type.title, image: type.image) { _ in
            
            NotificationPresenter.shared().present(text: "Downloading track")
            NotificationPresenter.shared().displayActivityIndicator(true)
            let trackFilename = "\(track.artistName) - \(track.title) - \(track.albumTitle).mp3".toUnixFilename
            let filename = "Music/\(trackFilename)"
            if let directoryURL = LibraryManager.getAbsolutePath(filename: filename, path: .documentDirectory),
               let trackURL = URL(string: track.onlineLink) {
                URLSession.shared.downloadTask(with: trackURL) { tempFileURL, response, error in
                    if let trackTempURL = tempFileURL {
                        do {
                            let trackData = try Data(contentsOf: trackTempURL)
                            try trackData.write(to: directoryURL)
                            DispatchQueue.main.async {
                                delegate.stopDownloadSpinner()
                                RealmManager<LibraryTrack>().update { realm in
                                    try? realm.write {
                                        track.cacheLink = filename
                                    }
                                }
                                
                                RealmManager<LibraryTrackInPlaylist>().read().forEach { trackInPlaylist in
                                    if trackInPlaylist.id == track.id {
                                        RealmManager<LibraryTrackInPlaylist>().update { realm in
                                            try? realm.write {
                                                trackInPlaylist.cacheLink = filename
                                            }
                                        }
                                    }
                                }
                                
                                NotificationPresenter.shared().dismiss(animated: true)
                                let alert = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
                                delegate.present(alert: alert, haptic: .success)
                                delegate.reloadData()
                                completion?(filename)
                            }
                        } catch {
                            delegate.stopDownloadSpinner()
                            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: Localization.Alert.Message.errorDownload.rawValue.localized, preset: .error)
                            delegate.present(alert: alert, haptic: .error)
                        }
                    }
                }.resume()
            } else {
                delegate.stopDownloadSpinner()
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: Localization.Alert.Message.errorDownload.rawValue.localized, preset: .error)
                delegate.present(alert: alert, haptic: .error)
            }
        }
        
        return action
    }
    
    func deleteTrackFromCacheAction(track: LibraryTrack, completion: (() -> Void)? = nil) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.removeTrackFromCache
        let action = UIAction(title: type.title, image: type.image, attributes: .destructive) { _ in
            if let path = LibraryManager.getAbsolutePath(filename: track.cacheLink, path: .documentDirectory) {
                try? FileManager.default.removeItem(at: path)
                RealmManager<LibraryTrack>().read().forEach { trackInDb in
                    if trackInDb.id == track.id {
                        RealmManager<LibraryTrack>().update { realm in
                            try? realm.write({
                                trackInDb.cacheLink = ""
                            })
                        }
                    }
                }
                
                RealmManager<LibraryTrackInPlaylist>().read().forEach { trackInPlaylist in
                    if trackInPlaylist.id == track.id {
                        RealmManager<LibraryTrackInPlaylist>().update { realm in
                            try? realm.write({
                                trackInPlaylist.cacheLink = ""
                            })
                        }
                    }
                }
                
                let alert = SPAlertView(title: Localization.Alert.Title.success.rawValue, preset: .done)
                delegate.present(alert: alert, haptic: .success)
                delegate.reloadData()
                completion?()
            } else {
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, preset: .error)
                delegate.present(alert: alert, haptic: .error)
            }
        }
        
        return action
    }
    
    func addToPlaylistAction(_ track: LibraryTrack) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.addToPlaylist
        let action = UIAction(title: type.title, image: type.image) { _ in
            let addToPlaylistVC = AddToPlaylistController()
            addToPlaylistVC.delegate = delegate
            addToPlaylistVC.set(track)
            let navVC = UINavigationController(rootViewController: addToPlaylistVC)
            delegate.present(navVC)
        }
        
        return action
    }
    
    func addSongToPlaylistAction(track: LibraryTrack, playlist: LibraryPlaylist) -> UIAlertAction? {
        guard let delegate else { return nil }
        
        let action = UIAlertAction(title: ActionsEnum.ActionsWithoutImage.addAnyway.title, style: .default) { _ in
            let newTrack = LibraryTrackInPlaylist(id: track.id, title: track.title, duration: track.duration, trackPosition: track.trackPosition, diskNumber: track.diskNumber, isExplicit: track.isExplicit, artistID: track.artistID, artistName: track.artistName, albumID: track.albumID, albumName: track.albumTitle, onlineLink: track.onlineLink, cacheLink: track.cacheLink, coverLink: track.coverLink, playlistID: playlist.id)
            RealmManager<LibraryTrackInPlaylist>().write(object: newTrack)
            
            playlist.updateIsExplicit()
            let alert = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
            delegate.present(alert: alert, haptic: .success)
            delegate.dismiss()
        }
        
        action.setValue(SettingsManager.getColor.color, forKey: "titleTextColor")
        return action
    }
    
    var cancelAddingSongToPlaylistAction: UIAlertAction? {
        guard let delegate else { return nil }
        
        let action = UIAlertAction(title: Localization.Alert.Action.skipAdding.rawValue.localized, style: .destructive) { _ in
            delegate.dismiss()
        }
        
        return action
    }
    
    func deletePlaylistFromLibraryAction(_ playlist: LibraryPlaylist) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.removePlaylistFromLibrary
        let action = UIAction(title: type.title, image: type.image, attributes: .destructive) { _ in
            if let pathString = LibraryManager.getAbsolutePath(filename: playlist.image, path: .documentDirectory),
               FileManager.default.fileExists(atPath: pathString.path) {
                if !ImageManager.deleteLocalImage(playlist.image) {
                    return
                }
            }
            
            RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == playlist.id }).forEach { track in
                RealmManager<LibraryTrackInPlaylist>().delete(object: track)
            }
            
            RealmManager<LibraryPlaylist>().delete(object: playlist)
            let alert = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
            delegate.present(alert: alert, haptic: .success)
            delegate.reloadData()
            delegate.popVC()
        }
        
        return action
    }
    
    func likeTrackAction(_ trackID: Int) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.likeTrack
        let action = UIAction(title: type.title, image: type.image) { _ in
            let alert = SPAlertView(title: "", preset: .spinner)
            delegate.present(alert: alert, haptic: .none)
            DeezerProvider.getTrack(trackID) { track in
                let trackPosition = track.trackPosition ?? 0
                let diskNumber = track.diskNumber ?? 0
                guard let artist = track.artist,
                      let album = track.album
                else { return }
                
                let trackInLibrary = LibraryTrack(id: track.id, title: track.title, duration: track.duration, trackPosition: trackPosition, diskNumber: diskNumber, isExplicit: track.isExplicit, artistID: artist.id, artistName: artist.name, albumID: album.id, albumName: album.title, onlineLink: track.downloadLink, cacheLink: "", coverLink: "")
                RealmManager<LibraryTrack>().write(object: trackInLibrary)
                LibraryManager.downloadArtworks()
                delegate.dismiss(alert)
                let alert = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .heart)
                delegate.present(alert: alert, haptic: .success)
                delegate.reloadData()
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                delegate.present(alert: alert, haptic: .error)
            }
        }
        
        return action
    }
    
    func removeTrackFromPlaylist(track trackInPlaylist: LibraryTrackInPlaylist, playlistID: String) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.removeTrackFromPlaylist
        let action = UIAction(title: type.title, image: type.image, attributes: .destructive) { _ in
            var alert = SPAlertView(title: "", preset: .spinner)
            alert.dismissByTap = false
            delegate.present(alert: alert, haptic: .none)
            RealmManager<LibraryTrackInPlaylist>().delete(object: trackInPlaylist)
            RealmManager<LibraryPlaylist>().update { realm in
                var isExplicit = false
                RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == playlistID}).forEach { track in
                    if track.isExplicit {
                        isExplicit = true
                    }
                }
                
                guard let playlist = RealmManager<LibraryPlaylist>().read().first(where: { $0.id == playlistID }) else { return }
                try? realm.write {
                    playlist.isExplicit = isExplicit
                }
            }
            
            delegate.dismiss(alert)
            alert = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
            delegate.present(alert: alert, haptic: .success)
            delegate.reloadData()
        }
        
        return action
    }
}
