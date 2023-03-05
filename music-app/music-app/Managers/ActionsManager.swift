//
//  ActionsManager.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 3.03.23.
//

import UIKit
import SPAlert

final class ActionsManager {
    private enum ActionsEnum {
        case showArtist
        case showAlbum
        case removeTrackFromLibrary
        
        var title: String {
            switch self {
                case .showArtist:
                    return Localization.MenuActions.showArtist.rawValue.localized
                case .showAlbum:
                    return Localization.MenuActions.showAlbum.rawValue.localized
                case .removeTrackFromLibrary:
                    return Localization.MenuActions.removeFromLibrary.rawValue
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
            }
        }
    }
    
    weak var delegate: MenuActionsDelegate?
    
    func showArtistAction(_ artist: DeezerArtist) -> UIAction? {
        guard let delegate else { return nil }
        
        let type = ActionsEnum.showArtist
        let action = UIAction(title: type.title, subtitle: artist.name, image: type.image) { _ in
            DeezerProvider.getArtist(artist.id) { artist in
                let artistVC = ArtistController()
                artistVC.set(artist)
                delegate.dismissViewController()
                delegate.pushViewController(artistVC)
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
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
                delegate.dismissViewController()
                delegate.pushViewController(albumVC)
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
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
                let alertView = SPAlertView(title: , preset: <#T##SPAlertIconPreset#>)
            } else {
                let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                delegate.present(alert: alertView, haptic: .error)
            }
        }
        
        return action
    }
}
