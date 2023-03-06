//
//  TextPlaylistInfoCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.03.23.
//

import UIKit

class TextPlaylistInfoCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    
    static let id = String(describing: TextPlaylistInfoCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ playlist: LibraryPlaylist) {
        infoLabel.text = "\(playlist.countOfTracks) song\(playlist.countOfTracks > 1 ? "s" : ""), \(playlist.duration.durationInMinutes)"
    }
    
}
