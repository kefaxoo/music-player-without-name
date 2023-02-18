//
//  AlbumTrackCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit

class AlbumTrackCell: UITableViewCell {

    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explicitImageView: UIImageView!
    @IBOutlet weak var inLibraryImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    
    static let id = String(describing: AlbumTrackCell.self)
    
    private var track: DeezerTrack?
    
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
        inLibraryImageView.isHidden = !LibraryManager.isTrackInLibrary(track.id)
    }
    
}
