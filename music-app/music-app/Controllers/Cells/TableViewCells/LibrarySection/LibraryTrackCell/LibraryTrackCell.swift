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
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var downloadImageView: UIImageView!
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
        if let path = LibraryManager.getAbsolutePath(filename: track.coverLink, path: .documentDirectory),
           let imageData = try? Data(contentsOf: path) {
            coverView.image = UIImage(data: imageData)
        } else {
            DeezerProvider.getAlbum(track.albumID) { album in
                self.coverView.sd_setImage(with: URL(string: album.coverSmall))
            } failure: { error in
                print(error)
            }
        }
        
        self.artistLabel.text = track.artistName
        titleLabel.text = track.title
        explicitImageView.isHidden = !track.isExplicit
        explicitImageView.tintColor = SettingsManager.getColor.color
        self.downloadImageView.isHidden = !LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle)
        self.downloadImageView.tintColor = SettingsManager.getColor.color
        self.downloadIndicator.isHidden = true
        self.downloadIndicator.color = SettingsManager.getColor.color
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let track = self.track else { return }
        
        let actionsManager = ActionsManager()
        actionsManager.delegate = self
        
        var actions = [UIAction]()
        
        guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id),
              let addToPlaylistAction = actionsManager.addToPlaylistAction(track)
        else { return }
        
        actions.append(removeFromLibraryAction)
        if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
            guard let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track) else { return }
            
            actions.append(removeTrackFromCacheAction)
        } else {
            guard let downloadTrackAction = actionsManager.downloadTrackAction(track) else { return }
            
            actions.append(downloadTrackAction)
        }
        
        actions.append(addToPlaylistAction)
        
        let libraryActionsMenu = UIMenu(options: .displayInline, children: actions)
        
        guard let shareSongAction = actionsManager.shareSongAction(track.id),
              let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track)
        else { return }
        
        let shareActionsMenu = UIMenu(options: .displayInline, children: [shareSongAction, shareLinkAction])
        
        guard let showAlbumAction = actionsManager.showAlbumAction(id: track.albumID, title: track.albumTitle),
              let showArtistAction = actionsManager.showArtistAction(track.artistID)
        else { return }
        
        let showActionsMenu = UIMenu(options: .displayInline, children: [showAlbumAction, showArtistAction])
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(children: [libraryActionsMenu, shareActionsMenu, showActionsMenu])
    }
}

extension LibraryTrackCell: MenuActionsDelegate {
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        alert.present(haptic: haptic)
    }
    
    func present(_ vc: UIActivityViewController) {
        if let delegate {
            delegate.present(vc)
        }
    }
    
    func dismiss(_ alert: SPAlertView) {
        alert.dismiss()
    }
    
    func reloadData() {
        if let delegate {
            delegate.reloadData()
        }
    }
    
    func pushViewController(_ vc: UIViewController) {
        if let delegate {
            delegate.pushViewController(vc)
        }
    }
    
    func startDonwloadSpinner() {
        downloadIndicator.startAnimating()
        downloadIndicator.isHidden = false
    }
    
    func stopDownloadSpinner() {
        downloadIndicator.stopAnimating()
        downloadIndicator.isHidden = true
        if let delegate {
            delegate.reloadData()
        }
    }
    
    func present(_ vc: UIViewController) {
        if let delegate {
            delegate.present(vc)
        }
    }
}
