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
        DeezerProvider().getAlbum(track.albumID) { album in
            self.album = album.title
            self.coverView.sd_setImage(with: URL(string: album.coverSmall)!)
        } failure: { error in
            print(error)
        }
        
        DeezerProvider().getArtist(track.artistID) { artist in
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
        
        let removeFromLibraryAction = UIAction(title: MenuActionsEnum.removeFromLibrary.rawValue, image: MenuActionsEnum.removeFromLibrary.image) { _ in
            guard let removingTrack = RealmManager<LibraryTrack>().read().first(where: { $0.id == track.id }) else { return }
            
            RealmManager<LibraryTrack>().delete(object: removingTrack)
            let alertView = SPAlertView(title: "Success", preset: .done)
            alertView.present(haptic: .success)
            delegate.reloadData()
        }
        
        let libraryActionsMenu = UIMenu(options: .displayInline, children: [removeFromLibraryAction])
        
        var shareActions = [UIAction]()
        let shareSongAction = UIAction(title: MenuActionsEnum.shareSong.rawValue, image: MenuActionsEnum.shareSong.image) { _ in
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
            guard let track = self.track else { return }
            
            let shareLink = "https://deezer.com/track/\(track.id)"
            SongLinkProvider().getShareLink(shareLink) { link in
                let text = "Listen \(track.title) by \(self.artist)\n\(link)"
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
