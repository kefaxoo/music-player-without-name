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
    @IBOutlet weak var inLibraryImageView: UIImageView!
    @IBOutlet weak var downloadImageView: UIImageView!
    
    static let id = String(describing: SongCell.self)
    
    private var track: DeezerTrack?
    
    weak var delegate: MenuActionsDelegate?
    
    private var isArtistController = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(track: DeezerTrack, isArtistController: Bool = false) {
        guard let album = track.album,
              let artist = track.artist?.name,
              let url = URL(string: album.coverSmall)
        else { return }
        
        self.track = track
        coverImageView.sd_setImage(with: url)
        titleLabel.text = track.title
        explicitImageView.isHidden = !track.isExplicit
        explicitImageView.tintColor = SettingsManager.getColor.color
        artistAndAlbumLabel.text = "\(artist) • \(album.title)"
        inLibraryImageView.tintColor = SettingsManager.getColor.color
        downloadImageView.tintColor = SettingsManager.getColor.color
        inLibraryImageView.isHidden = true
        downloadImageView.isHidden = true
        self.isArtistController = isArtistController
        
        
        if LibraryManager.isTrackDownloaded(artist: artist, title: track.title, album: album.title) {
            downloadImageView.isHidden = false
        } else if LibraryManager.isTrackInLibrary(track.id) {
            inLibraryImageView.isHidden = false
        }
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let track,
              let artist = track.artist,
              let album = track.album
        else { return }
        
        let actionsManager = ActionsManager()
        actionsManager.delegate = self
        
        var librarySection = [UIAction]()
        if LibraryManager.isTrackInLibrary(track.id) {
            guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return }
            
            librarySection.append(removeFromLibraryAction)
            if LibraryManager.isTrackDownloaded(artist: artist.name, title: track.title, album: album.title) {
                guard let libraryTrack = LibraryTrack.getLibraryTrack(track),
                      let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track: libraryTrack) else { return }
                
                librarySection.append(removeTrackFromCacheAction)
            } else {
                guard let libraryTrack = LibraryTrack.getLibraryTrack(track),
                      let downloadTrackAction = actionsManager.downloadTrackAction(track: libraryTrack) else { return }
                
                librarySection.append(downloadTrackAction)
            }
        } else {
            guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return }
            
            librarySection.append(addToLibraryAction)
        }
        
        guard let libraryTrack = LibraryTrack.getLibraryTrack(track),
              let addToPlaylistAction = actionsManager.addToPlaylistAction(libraryTrack) else { return }
        
        librarySection.append(addToPlaylistAction)
        let libraryMenu = UIMenu(options: .displayInline, children: librarySection)
        guard let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track),
              let shareSongAction = actionsManager.shareSongAction(track.id)
        else { return }
        
        let shareMenu = UIMenu(options: .displayInline, children: [shareLinkAction, shareSongAction])
        
        var showActions = [UIAction]()
        if !isArtistController {
            guard let showArtistAction = actionsManager.showArtistAction(artist.id) else { return }
            
            showActions.append(showArtistAction)
        }
        
        guard let showAlbumAction = actionsManager.showAlbumAction(album.id) else { return }
        
        showActions.append(showAlbumAction)
        let showMenu = UIMenu(options: .displayInline, children: showActions)
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(options: .displayInline, children: [libraryMenu, shareMenu, showMenu])
    }
}

extension SongCell: MenuActionsDelegate {
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
