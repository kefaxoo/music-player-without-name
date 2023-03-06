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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ playlist: LibraryPlaylist) {
        coverView.image = ImageManager.loadLocalImage(playlist.image)
        coverView.layer.cornerRadius = 20
        nameLabel.text = playlist.name
        explicitImageView.isHidden = !playlist.isExplicit
        setLocale()
    }
    
    func setLocale() {
        playButton.setTitle(Localization.Controller.Library.Playlist.PlaylistInfoCell.playButton.rawValue.localized, for: .normal)
        shuffleButton.setTitle(Localization.Controller.Library.Playlist.PlaylistInfoCell.shuffleButton.rawValue.localized, for: .normal)
    }
}
