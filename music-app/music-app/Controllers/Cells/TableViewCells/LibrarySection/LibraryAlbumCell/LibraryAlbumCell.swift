//
//  LibraryAlbumCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 13.02.23.
//

import UIKit
import SDWebImage
import SPAlert

class LibraryAlbumCell: UITableViewCell {

    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var explicitView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var lowerStackView: UIStackView!
    
    static let id = String(describing: LibraryAlbumCell.self)
    
    private var album: DeezerAlbum?
    
    weak var delegate: MenuActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(_ album: DeezerAlbum) {
        guard let url = URL(string: album.coverBig),
              let artist = album.artist?.name
        else { return }
        
        self.album = album
        coverView.sd_setImage(with: url)
        titleLabel.text = album.title
        artistLabel.text = artist
        if let year = album.releaseDate?.year {
            releaseYearLabel.text = "\(year)"
        } else {
            if !album.isExplicit {
                lowerStackView.isHidden = true
            } else {
                releaseYearLabel.isHidden = true
            }
        }
        
        explicitView.isHidden = !album.isExplicit
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let album,
              let delegate
        else { return }
        
        let shareAction = UIAction(title: MenuActionsEnum.shareLink.rawValue, image: MenuActionsEnum.shareLink.image) {  _ in
            guard let artist = album.artist?.name else { return }
            
            let shareLink = "https://deezer.com/album/\(album.id)"
            SongLinkProvider().getShareLink(shareLink) { link in
                let text = "Listen \(album.title) by \(artist)\n\(link)"
                let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                activityViewController.excludedActivityTypes = [.airDrop, .mail, .message]
                delegate.presentActivityController(activityViewController)
            } failure: { error in
                let alertView = SPAlertView(title: "Error", preset: .error)
                alertView.duration = 5
                alertView.present(haptic: .error)
            }

        }
        
        let shareMenu = UIMenu(options: .displayInline, children: [shareAction])
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(options: .displayInline, children: [shareMenu])
    }
    
}
