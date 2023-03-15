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
        coverView.layer.cornerRadius = 5
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
        guard let track else { return }
        
        let actionsManager = ActionsManager()
        actionsManager.delegate = self
        var playlistSection = [UIAction]()
        guard let removeFromPlaylistAction = actionsManager.removeTrackFromPlaylist(track: track, playlistID: track.playlistID)
        else { return }
        
        playlistSection.append(removeFromPlaylistAction)
        let playlistMenu = UIMenu(options: .displayInline, children: playlistSection)
        var librarySection = [UIAction]()
        if LibraryManager.isTrackInLibrary(track.id) {
            guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return }
            
            librarySection.append(removeFromLibraryAction)
            if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
                guard let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track: LibraryTrack.getLibraryTrack(track)) else { return }
                
                librarySection.append(removeTrackFromCacheAction)
            } else {
                guard let downloadTrackAction = actionsManager.downloadTrackAction(track: LibraryTrack.getLibraryTrack(track)) else { return }
                
                librarySection.append(downloadTrackAction)
            }
        } else {
            guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return }
            
            librarySection.append(addToLibraryAction)
        }
        
        guard let addToPlaylistAction = actionsManager.addToPlaylistAction(LibraryTrack.getLibraryTrack(track)) else { return }
        
        librarySection.append(addToPlaylistAction)
        let libraryMenu = UIMenu(options: .displayInline, children: librarySection)
        guard let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track),
              let shareSongAction = actionsManager.shareSongAction(track.id)
        else { return }
        
        let shareMenu = UIMenu(options: .displayInline, children: [shareLinkAction, shareSongAction])
        
        guard let showArtistAction = actionsManager.showArtistAction(track.artistID),
              let showAlbumAction = actionsManager.showAlbumAction(id: track.albumID, title: track.albumTitle)
        else { return }
        
        let showMenu = UIMenu(options: .displayInline, children: [showArtistAction, showAlbumAction])
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(options: .displayInline, children: [playlistMenu, libraryMenu, shareMenu, showMenu])
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
    
    func present(_ vc: UIViewController) {
        if let delegate {
            delegate.present(vc)
        }
    }
    
    func present(_ vc: UIActivityViewController) {
        if let delegate {
            delegate.present(vc)
        }
    }
    
    func pushViewController(_ vc: UIViewController) {
        if let delegate {
            delegate.pushViewController(vc)
        }
    }
}
