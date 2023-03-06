//
//  PlaylistCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.03.23.
//

import UIKit

class PlaylistCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var playlist: LibraryPlaylist?

    static let id = String(describing: PlaylistCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ playlist: LibraryPlaylist) {
        self.playlist = playlist
        if let cover = ImageManager.loadLocalImage(playlist.image) {
            self.coverImageView.image = cover
        }
        
        titleLabel.text = playlist.name
    }
    
}
