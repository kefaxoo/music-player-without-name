//
//  LibraryTrackCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import UIKit
import SPAlert

class LibraryTrackCell: UITableViewCell {

    static let id = String(describing: LibraryTrackCell.self)
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explicitImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    private var track: LibraryTrack?
    private var artist = ""
    private var album = ""
    
    weak var delegate: MenuActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ track: LibraryTrack) {
        self.track = track
        DeezerProvider.getAlbum(track.albumID) { album in
            self.album = album.title
            self.coverView.sd_setImage(with: URL(string: album.coverSmall)!)
        } failure: { error in
            print(error)
        }
        
        DeezerProvider.getArtist(track.artistID) { artist in
            self.artist = artist.name
            self.artistLabel.text = artist.name
        } failure: { error in
            print(error)
        }
        
        titleLabel.text = track.title
        explicitImageView.isHidden = !track.isExplicit
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let track = self.track,
              let delegate
        else { return }
        
        let removeFromLibraryAction = UIAction(title: MenuActionsEnum.removeFromLibrary.title, image: MenuActionsEnum.removeFromLibrary.image) { _ in
            guard let removingTrack = RealmManager<LibraryTrack>().read().first(where: { $0.id == track.id }) else { return }
            
            RealmManager<LibraryTrack>().delete(object: removingTrack)
            let alertView = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
            alertView.present(haptic: .success)
            delegate.reloadData()
        }
        
        let libraryActionsMenu = UIMenu(options: .displayInline, children: [removeFromLibraryAction])
        
        let shareSongAction = UIAction(title: MenuActionsEnum.shareSong.title, image: MenuActionsEnum.shareSong.image) { _ in
            let alertView = SPAlertView(title: "", preset: .spinner)
            alertView.dismissByTap = false
            alertView.present()
            
            guard let track = self.track else { return }
            
            let tempDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let trackName = "\(self.artist) - \(track.title) - \(self.album).mp3"
            let trackDirectoryURL = tempDirectoryURL.appendingPathComponent(trackName.toUnixFilename)
            let downloadLink = "https://dz.loaderapp.info/deezer/128/https://deezer.com/track/\(track.id)"
            if let trackURL = URL(string: downloadLink) {
                URLSession.shared.downloadTask(with: trackURL) { (tempFileUrl, response, error) in
                    if let trackTempFileUrl = tempFileUrl {
                        do {
                            let trackData = try Data(contentsOf: trackTempFileUrl)
                            try trackData.write(to: trackDirectoryURL)
                            DispatchQueue.main.async {
                                let activityViewController = UIActivityViewController(activityItems: [trackDirectoryURL], applicationActivities: nil)
                                activityViewController.excludedActivityTypes = [.airDrop, .mail, .message]
                                alertView.dismiss()
                                delegate.presentActivityController(activityViewController)
                                activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                    if completed {
                                        do {
                                            try FileManager.default.removeItem(at: trackDirectoryURL)
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            }
                        } catch {
                            alertView.dismiss()
                            let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                            alertView.duration = 5
                            alertView.present(haptic: .error)
                        }
                    }
                }.resume()
            }
        }
        
        let shareLinkAction = UIAction(title: MenuActionsEnum.shareLink.title, image: MenuActionsEnum.shareLink.image) { _ in
            guard let track = self.track else { return }
            
            let shareLink = "https://deezer.com/track/\(track.id)"
            SongLinkProvider().getShareLink(shareLink) { link in
                let text = Localization.MenuActions.ShareLink.shareMessage.rawValue.localizedWithParameters(title: track.title, artist: self.artist, link: link)
                let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                activityViewController.excludedActivityTypes = [.airDrop, .mail, .message]
                delegate.presentActivityController(activityViewController)
            } failure: { error in
                let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                alertView.duration = 5
                alertView.present(haptic: .error)
            }
        }
        
        let shareActionsMenu = UIMenu(options: .displayInline, children: [shareSongAction, shareLinkAction])
        
        let showAlbumAction = UIAction(title: MenuActionsEnum.showAlbum.title, image: MenuActionsEnum.showAlbum.image) { _ in
            var alert = SPAlertView(title: "", preset: .spinner)
            alert.dismissByTap = false
            alert.present()
            DeezerProvider.getAlbum(track.albumID) { album in
                let albumVC = AlbumController()
                albumVC.set(album)
                alert.dismiss()
                delegate.pushViewController(albumVC)
            } failure: { error in
                alert.dismiss()
                alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: error, preset: .error)
                alert.present(haptic: .error)
            }
        }
        
        let showActionsMenu = UIMenu(options: .displayInline, children: [showAlbumAction])
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(children: [libraryActionsMenu, shareActionsMenu, showActionsMenu])
    }
}
