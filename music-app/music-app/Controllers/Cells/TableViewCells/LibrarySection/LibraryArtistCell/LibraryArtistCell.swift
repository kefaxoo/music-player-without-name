//
//  LibraryArtistCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 13.02.23.
//

import UIKit

class LibraryArtistCell: UITableViewCell {

    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    
    static let id = String(describing: LibraryArtistCell.self)
    
    private var artist: DeezerArtist?
    
    weak var delegate: MenuActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ artist: DeezerArtist) {
        guard let imageLink = artist.pictureSmall,
              let url = URL(string: imageLink)
        else { return }
        
        artistImageView.sd_setImage(with: url)
        artistImageView.layer.masksToBounds = false
        artistImageView.layer.cornerRadius = artistImageView.frame.height / 2
        artistImageView.clipsToBounds = true
        
        artistLabel.text = artist.name
    }
    
}
