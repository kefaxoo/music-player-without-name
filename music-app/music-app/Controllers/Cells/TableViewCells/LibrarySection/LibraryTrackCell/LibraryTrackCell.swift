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
        if LibraryManager.isCoverDownloaded(artist: track.artistName, album: track.albumTitle) {
            coverView.image = ImageManager.loadLocalImage(track.coverLink)
        } else {
            DeezerProvider.getAlbum(track.albumID) { album in
                self.coverView.sd_setImage(with: URL(string: album.coverSmall))
            } failure: { error in
                print(error)
            }
        }
        
        coverView.layer.cornerRadius = 5
        self.artistLabel.text = track.artistName
        titleLabel.text = track.title
        explicitImageView.isHidden = !track.isExplicit
        explicitImageView.tintColor = SettingsManager.getColor.color
        self.downloadImageView.isHidden = !LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle)
        self.downloadImageView.tintColor = SettingsManager.getColor.color
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let track = self.track else { return }
        
        let actionsManager = ActionsManager()
        actionsManager.delegate = self
        
        var librarySection = [UIAction]()
        if LibraryManager.isTrackInLibrary(track.id) {
            guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return }
            
            librarySection.append(removeFromLibraryAction)
            if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
                guard let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track: track) else { return }
                
                librarySection.append(removeTrackFromCacheAction)
            } else {
                guard let downloadTrackAction = actionsManager.downloadTrackAction(track: track) else { return }
                
                librarySection.append(downloadTrackAction)
            }
        } else {
            guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return }
            
            librarySection.append(addToLibraryAction)
        }
        
        guard let addToPlaylistAction = actionsManager.addToPlaylistAction(track) else { return }
        
        librarySection.append(addToPlaylistAction)
        let libraryMenu = UIMenu(options: .displayInline, children: librarySection)
        guard let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track),
              let shareSongAction = actionsManager.shareSongAction(track.id)
        else { return }
        
        let shareMenu = UIMenu(options: .displayInline, children: [shareLinkAction, shareSongAction])
        
        var showActions = [UIAction]()
        guard let showArtistAction = actionsManager.showArtistAction(track.artistID) else { return }
        
        showActions.append(showArtistAction)
        guard let showAlbumAction = actionsManager.showAlbumAction(track.albumID) else { return }
        
        showActions.append(showAlbumAction)
        let showMenu = UIMenu(options: .displayInline, children: showActions)
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(options: .displayInline, children: [libraryMenu, shareMenu, showMenu])
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
    
    func present(_ vc: UIViewController) {
        if let delegate {
            delegate.present(vc)
        }
    }
}
