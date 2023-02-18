//
//  AlbumInfoCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit
import SDWebImage

class AlbumInfoCell: UITableViewCell {

    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistButton: UIButton!
    @IBOutlet weak var albumInfoLabel: UILabel!
    @IBOutlet weak var explicitImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    
    static let id = String(String(describing: AlbumInfoCell.self))
    
    private var album: DeezerAlbum?
    private var artistID: Int?
    
    weak var delegate: ViewControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLocale()
    }
    
    // TODO:
    @IBAction func artistButtonDidTap(_ sender: Any) {
        guard let delegate else { return }
        let artistVC = ArtistController()
        delegate.pushVC(artistVC)
    }
    
    private func setLocale() {
        playButton.setTitle(Localization.Controller.Album.AlbumInfoCell.playButton.rawValue.localized, for: .normal)
        shuffleButton.setTitle(Localization.Controller.Album.AlbumInfoCell.shuffleButton.rawValue.localized, for: .normal)
    }
    
    func set(_ album: DeezerAlbum) {
        self.album = album
        if let url = URL(string: album.coverBig) {
            coverView.sd_setImage(with: url)
        }
        
        guard let artist = album.artist else { return }
        
        titleLabel.text = album.title
        artistButton.setTitle(artist.name, for: .normal)
        artistID = artist.id
        if let genre = album.genres?.data.first {
            albumInfoLabel.text = "\(genre.name)"
        }
        
        if let year = album.releaseDate?.year {
            if let text = albumInfoLabel.text,
               !text.isEmpty {
                albumInfoLabel.text?.append(" • ")
            }
            
            albumInfoLabel.text?.append("\(year)")
        }
        
        explicitImageView.isHidden = !album.isExplicit
    }
    
}
