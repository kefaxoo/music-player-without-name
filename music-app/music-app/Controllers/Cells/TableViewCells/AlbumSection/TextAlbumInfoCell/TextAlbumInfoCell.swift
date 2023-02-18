//
//  TextAlbumInfoCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit

class TextAlbumInfoCell: UITableViewCell {

    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var countOfSongsAndDurationLabel: UILabel!
    @IBOutlet weak var recordingLabelLabel: UILabel!
    
    static let id = String(describing: TextAlbumInfoCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ album: DeezerAlbum) {
        guard let releaseDate = album.releaseDate,
              let tracks = album.tracks?.data,
              let label = album.label
        else { return }
        
        releaseDateLabel.text = releaseDate.humanDate
        var duration = 0
        tracks.forEach { track in
            duration += track.duration
        }
        
        countOfSongsAndDurationLabel.text = "\(tracks.count) song\(tracks.count > 1 ? "s" : ""), \(duration.durationInMinutes)"
        
        recordingLabelLabel.text = label
    }
    
}
