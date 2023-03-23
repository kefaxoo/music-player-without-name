//
//  ArtistInfoCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 19.02.23.
//

import UIKit
import SDWebImage

class ArtistInfoCell: UITableViewCell {

    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    
    static let id = String(describing: ArtistInfoCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ artist: DeezerArtist) {
        if let link = artist.pictureBig {
            artistImageView.sd_setImage(with: URL(string: link))
            artistImageView.layer.cornerRadius = 100 / 2
        }
        
        artistLabel.text = artist.name
        self.selectionStyle = .none
    }
    
}
