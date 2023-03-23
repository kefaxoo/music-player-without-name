//
//  PlaylistInfoCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.03.23.
//

import UIKit

class PlaylistInfoCell: UITableViewCell {

    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var explicitImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    static var id = String(describing: PlaylistInfoCell.self)
    
    private var playlist: LibraryPlaylist?
    
    weak var audioPlayerDelegate: AudioPlayerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ playlist: LibraryPlaylist) {
        self.playlist = playlist
        coverView.image = ImageManager.loadLocalImage(playlist.image)
        coverView.layer.cornerRadius = 20
        nameLabel.text = playlist.name
        explicitImageView.isHidden = !playlist.isExplicit
        explicitImageView.tintColor = SettingsManager.getColor.color
        playButton.tintColor = SettingsManager.getColor.color
        shuffleButton.tintColor = SettingsManager.getColor.color
        self.selectionStyle = .none
        setLocale()
    }
    
    func setLocale() {
        playButton.setTitle(Localization.Controller.Library.Playlist.PlaylistInfoCell.playButton.rawValue.localized, for: .normal)
        shuffleButton.setTitle(Localization.Controller.Library.Playlist.PlaylistInfoCell.shuffleButton.rawValue.localized, for: .normal)
    }
    
    @IBAction func playButtonDidTap(_ sender: Any) {
        guard let playlist else { return }
        
        var tracks = [LibraryTrack]()
        RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == playlist.id }).forEach { track in
            tracks.append(LibraryTrack.getLibraryTrack(track))
        }
        
        guard let firstTrack = tracks.first else { return }
        
        AudioPlayer.set(track: firstTrack, playlist: tracks, indexInPlaylist: 0)
        AudioPlayer.nowPlayingViewDelegate = audioPlayerDelegate
    }
    
    
    @IBAction func shuffleButtonDidTap(_ sender: Any) {
        guard let playlist else { return }
        
        var tracks = [LibraryTrack]()
        RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == playlist.id }).forEach { track in
            tracks.append(LibraryTrack.getLibraryTrack(track))
        }
        
        tracks = tracks.shuffled()
        guard let firstTrack = tracks.first else { return }
        
        AudioPlayer.set(track: firstTrack, playlist: tracks, indexInPlaylist: 0)
        AudioPlayer.nowPlayingViewDelegate = audioPlayerDelegate
    }
}
