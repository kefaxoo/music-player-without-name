//
//  SongCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import UIKit
import SDWebImage
import SPAlert

class SongCell: UITableViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explicitImageView: UIImageView!
    @IBOutlet weak var artistAndAlbumLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    static let id = String(describing: SongCell.self)
    
    private var track: DeezerTrack?
    
    weak var delegate: MenuActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ track: DeezerTrack) {
        guard let album = track.album,
              let artist = track.artist?.name,
              let url = URL(string: album.coverSmall)
        else { return }
        
        self.track = track
        coverImageView.sd_setImage(with: url)
        titleLabel.text = track.title
        explicitImageView.isHidden = !track.isExplicit
        artistAndAlbumLabel.text = "\(artist) • \(album.title)"
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let track = self.track,
              let delegate
        else { return }
        
        var libraryActions = [UIAction]()
        
        if LibraryManager.isTrackInLibrary(track.id) {
            let removeFromLibraryAction = UIAction(title: MenuActionsEnum.removeFromLibrary.rawValue, image: MenuActionsEnum.removeFromLibrary.image) { _ in
                guard let removingTrack = RealmManager<LibraryTrack>().read().first(where: { $0.id == track.id }) else { return }
                
                RealmManager<LibraryTrack>().delete(object: removingTrack)
                let alertView = SPAlertView(title: "Success", preset: .done)
                alertView.present(haptic: .success)
                delegate.reloadData()
            }
            
            libraryActions.append(removeFromLibraryAction)
        } else {
            let addToLibraryAction = UIAction(title: MenuActionsEnum.addToLibrary.rawValue, image: MenuActionsEnum.addToLibrary.image) { _ in
                let alertView = SPAlertView(title: "", preset: .spinner)
                alertView.dismissByTap = false
                alertView.present()
                DeezerProvider().getTrack(track.id, success: { track in
                    let newTrack = LibraryTrack(id: track.id, title: track.title, duration: track.duration, trackPosition: track.trackPosition!, diskNumber: track.diskNumber!, isExplicit: track.isExplicit, artistID: track.artist!.id, albumID: track.album!.id)
                    
                    RealmManager<LibraryTrack>().write(object: newTrack)
                    alertView.dismiss()
                    let alertView = SPAlertView(title: "Success", preset: .done)
                    alertView.present(haptic: .success)
                    delegate.reloadData()
                }, failure: { error in
                    alertView.dismiss()
                    let alertView = SPAlertView(title: "Error", message: error, preset: .error)
                    alertView.present(haptic: .error)
                })
            }
            
            libraryActions.append(addToLibraryAction)
        }
        
        let libraryActionsMenu = UIMenu(options: .displayInline, children: libraryActions)
        
        var shareActions = [UIAction]()
        let shareSongAction = UIAction(title: MenuActionsEnum.shareSong.rawValue, image: MenuActionsEnum.shareSong.image) { _ in
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
                            let alertView = SPAlertView(title: "Error", preset: .error)
                            alertView.duration = 5
                            alertView.present(haptic: .error)
                        }
                    }
                }.resume()
            }
        }
        
        shareActions.append(shareSongAction)
        
        let shareLinkAction = UIAction(title: MenuActionsEnum.shareLink.rawValue, image: MenuActionsEnum.shareLink.image) { _ in
            guard let track = self.track,
                  let artist = track.artist
            else { return }
            
            SongLinkProvider().getShareLink(track.shareLink) { link in
                let text = "Listen \(track.title) by \(artist.name)\n\(link)"
                let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                
                activityViewController.excludedActivityTypes = [.airDrop, .mail, .message]
                delegate.presentActivityController(activityViewController)
            } failure: { error in
                let alertView = SPAlertView(title: "Error", preset: .error)
                alertView.duration = 5
                alertView.present(haptic: .error)
            }
        }
        
        shareActions.append(shareLinkAction)
        let shareActionsMenu = UIMenu(options: .displayInline, children: shareActions)
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(children: [libraryActionsMenu, shareActionsMenu])
    }
}
