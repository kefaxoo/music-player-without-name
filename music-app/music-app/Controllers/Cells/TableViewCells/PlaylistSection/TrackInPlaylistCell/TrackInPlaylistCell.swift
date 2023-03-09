//
//  TrackInPlaylistCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.03.23.
//

import UIKit
import SPAlert

class TrackInPlaylistCell: UITableViewCell {

    static let id = String(describing: TrackInPlaylistCell.self)
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explicitImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var likedImageView: UIImageView!
    @IBOutlet weak var downloadedImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    
    private var track: LibraryTrackInPlaylist?
    
    weak var delegate: MenuActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(_ track: LibraryTrackInPlaylist) {
        self.track = track
        coverView.image = ImageManager.loadLocalImage(track.coverLink)
        titleLabel.text = track.title
        artistLabel.text = track.artistName
        explicitImageView.isHidden = !track.isExplicit
        explicitImageView.tintColor = SettingsManager.getColor.color
        downloadedImageView.isHidden = true
        downloadedImageView.tintColor = SettingsManager.getColor.color
        likedImageView.isHidden = true
        likedImageView.tintColor = SettingsManager.getColor.color
        downloadedImageView.tintColor = SettingsManager.getColor.color
        if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
            downloadedImageView.isHidden = false
        } else if LibraryManager.isTrackInLibrary(track.id) {
            likedImageView.isHidden = false
        }
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let delegate,
              let track
        else { return }
        
        let actionsManager = ActionsManager()
        actionsManager.delegate = self
        
        var libraryActions = [UIAction]()
        
        if LibraryManager.isTrackInLibrary(track.id) {
            guard let deleteFromLibrary = actionsManager.removeFromLibrary(track.id) else { return }
            
            libraryActions.append(deleteFromLibrary)
            if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
                guard let deleteCacheFromLibrary = actionsManager.deleteTrackFromCacheAction(track.libraryTrack) else { return }
                
                libraryActions.append(deleteCacheFromLibrary)
            } else {
                guard let downloadTrackAction = actionsManager.downloadTrackAction(track.libraryTrack) else { return }
                
                libraryActions.append(downloadTrackAction)
            }
        } else {
            guard let likeTrack = actionsManager.likeTrackAction(track.id) else { return }
            
            libraryActions.append(likeTrack)
        }
        
        let librarySection = UIMenu(options: .displayInline, children: libraryActions)
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(options: .displayInline, children: [librarySection])
    }
    
}

extension TrackInPlaylistCell: MenuActionsDelegate {
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        if let delegate {
            delegate.present(alert: alert, haptic: haptic)
        }
    }
    
    func dismiss(_ alert: SPAlertView) {
        if let delegate {
            delegate.dismiss(alert)
        }
    }
    
    func reloadData() {
        if let delegate {
            delegate.reloadData()
        }
    }
}
