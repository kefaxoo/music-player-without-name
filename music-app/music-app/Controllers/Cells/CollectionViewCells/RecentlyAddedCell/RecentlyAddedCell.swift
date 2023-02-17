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
    @IBOutlet weak var creatorLabel: UILabel!
    
    static var id = String(describing: RecentlyAddedCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ item: DeezerAlbum) {
        self.titleLabel.text = item.title
        self.coverView.sd_setImage(with: URL(string: item.coverBig))
        self.creatorLabel.text = item.artist?.name
    }

    func set(_ item: LibraryTrack) {
        DeezerProvider.getAlbum(item.albumID) { album in
            self.titleLabel.text = item.title
            self.coverView.sd_setImage(with: URL(string: album.coverBig))
        } failure: { error in
            print(error)
        }
        
        DeezerProvider.getArtist(item.artistID) { artist in
            self.creatorLabel.text = artist.name
        } failure: { error in
            print(error)
        }

    }
}
