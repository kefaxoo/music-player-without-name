//
//  RecentlyAddedCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.02.23.
//

import UIKit

class RecentlyAddedCell: UICollectionViewCell {

    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    static var id = String(describing: RecentlyAddedCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ album: DeezerAlbum, _ artist: String = "") {
        self.titleLabel.text = album.title
        self.coverView.sd_setImage(with: URL(string: album.coverBig))
        if album.artist != nil {
            self.artistLabel.text = album.artist?.name
        } else {
            self.artistLabel.text = artist
        }
    }

    func set(_ track: LibraryTrack) {
        DeezerProvider.getAlbum(track.albumID) { album in
            self.titleLabel.text = track.title
            self.coverView.sd_setImage(with: URL(string: album.coverBig))
        } failure: { error in
            print(error)
        }
        
        DeezerProvider.getArtist(track.artistID) { artist in
            self.artistLabel.text = artist.name
        } failure: { error in
            print(error)
        }
    }
}
