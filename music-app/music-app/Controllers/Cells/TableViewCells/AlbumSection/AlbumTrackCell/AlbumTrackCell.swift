//
//  AlbumTrackCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit
import SPAlert

class AlbumTrackCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explicitImageView: UIImageView!
    @IBOutlet weak var inLibraryImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    
    static let id = String(describing: AlbumTrackCell.self)
    
    private var track: DeezerTrack?
    weak var delegate: MenuActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ track: DeezerTrack) {
        self.track = track
        
        DeezerProvider.getTrack(track.id) { track in
            guard let position = track.trackPosition else { return }
            
            self.positionLabel.text = "\(position)"
        } failure: { _ in
            self.positionLabel.isHidden = true
        }
        
        titleLabel.text = track.title
        explicitImageView.isHidden = !track.isExplicit
        inLibraryImageView.isHidden = !LibraryManager.isTrackInLibrary(track.id)
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let track = self.track,
              let delegate
        else { return }
        
        print(LibraryManager.isTrackInLibrary(track.id))
        
        var libraryActions = [UIAction]()
        
        if LibraryManager.isTrackInLibrary(track.id) {
            let removeFromLibraryAction = UIAction(title: MenuActionsEnum.removeFromLibrary.title, image: MenuActionsEnum.removeFromLibrary.image, attributes: .destructive) { _ in
                guard let removingTrack = RealmManager<LibraryTrack>().read().first(where: { $0.id == track.id }) else { return }
                
                RealmManager<LibraryTrack>().delete(object: removingTrack)
                let alertView = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
                alertView.present(haptic: .success)
                delegate.reloadData()
            }
            
            libraryActions.append(removeFromLibraryAction)
        } else {
            let addToLibraryAction = UIAction(title: MenuActionsEnum.addToLibrary.title, image: MenuActionsEnum.addToLibrary.image) { _ in
                let alertView = SPAlertView(title: "", preset: .spinner)
                alertView.dismissByTap = false
                alertView.present()
                DeezerProvider.getTrack(track.id, success: { track in
                    let newTrack = LibraryTrack(id: track.id, title: track.title, duration: track.duration, trackPosition: track.trackPosition!, diskNumber: track.diskNumber!, isExplicit: track.isExplicit, artistID: track.artist!.id, albumID: track.album!.id, onlineLink: "", cacheLink: "")
                    
                    RealmManager<LibraryTrack>().write(object: newTrack)
                    alertView.dismiss()
                    let alertView = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
                    alertView.present(haptic: .success)
                    delegate.reloadData()
                }, failure: { error in
                    alertView.dismiss()
                    let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: error, preset: .error)
                    alertView.present(haptic: .error)
                })
            }
            
            libraryActions.append(addToLibraryAction)
        }
        
        let libraryActionsMenu = UIMenu(options: .displayInline, children: libraryActions)
        
        let shareSongAction = UIAction(title: MenuActionsEnum.shareSong.title, image: MenuActionsEnum.shareSong.image) { _ in
            let alertView = SPAlertView(title: "", preset: .spinner)
            alertView.dismissByTap = false
            alertView.present()
            
            guard let artist = track.artist?.name,
                  let album = track.album?.title
            else { return }
            
            let tempDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let trackName = "\(artist) - \(track.title) - \(album).mp3"
            let trackDirectoryURL = tempDirectoryURL.appendingPathComponent(trackName.toUnixFilename)
            if let trackURL = URL(string: track.downloadLink) {
                URLSession.shared.downloadTask(with: trackURL) { (tempFileUrl, response, error) in
                    if let trackTempFileUrl = tempFileUrl {
                        do {
                            let trackData = try Data(contentsOf: trackTempFileUrl)
                            try trackData.write(to: trackDirectoryURL)
                            DispatchQueue.main.async {
                                let activityViewController = UIActivityViewController(activityItems: [trackDirectoryURL], applicationActivities: nil)
                                activityViewController.excludedActivityTypes = [.airDrop, .mail, .message]
                                alertView.dismiss()
                                delegate.present(activityViewController)
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
            guard let track = self.track,
                  let artist = track.artist
            else { return }
            
            SongLinkProvider().getShareLink(track.shareLink) { link in
                let text = Localization.MenuActions.ShareLink.shareMessage.rawValue.localizedWithParameters(title: track.title, artist: artist.name, link: link)
                let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                
                activityViewController.excludedActivityTypes = [.airDrop, .mail, .message]
                delegate.present(activityViewController)
            } failure: { error in
                let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                alertView.duration = 5
                alertView.present(haptic: .error)
            }
        }
        
        let shareActionsMenu = UIMenu(options: .displayInline, children: [shareSongAction, shareLinkAction])
        
        let showAlbumAction = UIAction(title: MenuActionsEnum.showAlbum.title, image: MenuActionsEnum.showAlbum.image) { _ in
            guard let albumID = track.album?.id else { return }
            
            var alert = SPAlertView(title: "", preset: .spinner)
            alert.dismissByTap = false
            alert.present()
            DeezerProvider.getAlbum(albumID) { album in
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
