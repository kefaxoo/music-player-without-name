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
    @IBOutlet weak var downloadImageView: UIImageView!
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
        explicitImageView.tintColor = SettingsManager.getColor.color
        inLibraryImageView.tintColor = SettingsManager.getColor.color
        downloadImageView.tintColor = SettingsManager.getColor.color
        downloadImageView.isHidden = true
        inLibraryImageView.isHidden = true
        guard let artist = track.artist?.name,
              let album = track.album?.title
        else { return }
        
        if LibraryManager.isTrackDownloaded(artist: artist, title: track.title, album: album) {
            downloadImageView.isHidden = false
            return
        } else if LibraryManager.isTrackInLibrary(track.id) {
            inLibraryImageView.isHidden = false
        }
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let track = self.track,
              let artist = track.artist?.name,
              let album = track.album?.title
        else { return }
        
        let actionsManager = ActionsManager()
        actionsManager.delegate = self
        
        var libraryActions = [UIAction]()
        
        if LibraryManager.isTrackInLibrary(track.id) {
            guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return }
            
            libraryActions.append(removeFromLibraryAction)
            if LibraryManager.isTrackDownloaded(artist: artist, title: track.title, album: album) {
                guard let libraryTrack = LibraryTrack.getLibraryTrack(track),
                      let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track: libraryTrack) else { return }
                
                libraryActions.append(removeTrackFromCacheAction)
            } else {
                guard let libraryTrack = LibraryTrack.getLibraryTrack(track),
                      let downloadTrackAction = actionsManager.downloadTrackAction(track: libraryTrack) else { return }
                
                libraryActions.append(downloadTrackAction)
            }
        } else {
            guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return }
            
            libraryActions.append(addToLibraryAction)
        }
        
        guard let libraryTrack = LibraryTrack.getLibraryTrack(track),
              let addToPlaylistAction = actionsManager.addToPlaylistAction(libraryTrack) else { return }
        
        libraryActions.append(addToPlaylistAction)
        
        let libraryActionsMenu = UIMenu(options: .displayInline, children: libraryActions)
        
        guard let shareSongAction = actionsManager.shareSongAction(track.id),
              let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track)
        else { return }
        
        let shareActionsMenu = UIMenu(options: .displayInline, children: [shareSongAction, shareLinkAction])
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(children: [libraryActionsMenu, shareActionsMenu])
    }
    
}

extension AlbumTrackCell: MenuActionsDelegate {
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        if let delegate {
            delegate.present(alert: alert, haptic: haptic)
        }
    }
    
    func popVC() {
        if let delegate {
            delegate.popVC()
        }
    }
    
    func dismiss(_ alert: SPAlertView) {
        if let delegate {
            delegate.dismiss(alert)
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
    
    func reloadData() {
        if let delegate {
            delegate.reloadData()
        }
    }
}
