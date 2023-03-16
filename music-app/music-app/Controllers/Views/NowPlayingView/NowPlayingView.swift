//
//  NowPlayingView.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 25.02.23.
//

import UIKit
import SDWebImage
import SPAlert

class NowPlayingView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var durationProgressView: UIProgressView!
    @IBOutlet weak var nextTrackButton: UIButton!
    
    private var track: DeezerTrack?
    var playlist: LibraryPlaylist?
    weak var delegate: MenuActionsDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: NowPlayingView.self), owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setInterface()
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
    
    func setInterface() {
        playPauseButton.tintColor = SettingsManager.getColor.color
        nextTrackButton.tintColor = SettingsManager.getColor.color
        durationProgressView.tintColor = SettingsManager.getColor.color
    }
    

    @IBAction func playPauseButtonDidTap(_ sender: Any) {
        if AudioPlayer.player.rate == 0 {
            AudioPlayer.pauseDidTap()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            AudioPlayer.playDidTap()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }

    @IBAction func nextTrackDidTap(_ sender: Any) {
        AudioPlayer.playNextTrack()
    }
}

extension NowPlayingView: MenuActionsDelegate {
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
    
    func reloadData() {
        if let delegate {
            delegate.reloadData()
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
}

extension NowPlayingView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            guard let track = AudioPlayer.currentTrack else { return UIMenu() }
            
            let actionsManager = ActionsManager()
            actionsManager.delegate = self
            var playlistSection = [UIAction]()
            if let trackInPlaylist = RealmManager<LibraryTrackInPlaylist>().read().first(where: { $0.id == track.id }),
               let playlist = self.playlist
            {
                if playlist.id == trackInPlaylist.playlistID {   
                    guard let removeFromPlaylistAction = actionsManager.removeTrackFromPlaylist(track: trackInPlaylist, playlistID: playlist.id) else { return UIMenu() }
                    
                    playlistSection.append(removeFromPlaylistAction)
                }
            }
            
            let playlistMenu = UIMenu(options: .displayInline, children: playlistSection)
            var librarySection = [UIAction]()
            if LibraryManager.isTrackInLibrary(track.id) {
                guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return UIMenu() }
                
                librarySection.append(removeFromLibraryAction)
                if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
                    guard let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track: track) else { return UIMenu() }
                    
                    librarySection.append(removeTrackFromCacheAction)
                } else {
                    guard let downloadTrackAction = actionsManager.downloadTrackAction(track: track) else { return UIMenu() }
                    
                    librarySection.append(downloadTrackAction)
                }
            } else {
                guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return UIMenu() }
                
                librarySection.append(addToLibraryAction)
            }
            
            guard let addToPlaylistAction = actionsManager.addToPlaylistAction(track) else { return UIMenu() }
            
            librarySection.append(addToPlaylistAction)
            let libraryMenu = UIMenu(options: .displayInline, children: librarySection)
            guard let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track),
                  let shareSongAction = actionsManager.shareSongAction(track.id)
            else { return UIMenu() }
            
            let shareMenu = UIMenu(options: .displayInline, children: [shareLinkAction, shareSongAction])
            
            guard let showArtistAction = actionsManager.showArtistAction(track.artistID),
                  let showAlbumAction = actionsManager.showAlbumAction(id: track.albumID, title: track.albumTitle)
            else { return UIMenu() }
            
            let showMenu = UIMenu(options: .displayInline, children: [showArtistAction, showAlbumAction])
            
            return UIMenu(options: .displayInline, children: [playlistMenu, libraryMenu, shareMenu, showMenu])
        }
    }
}
