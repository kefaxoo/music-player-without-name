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
        if let url = URL(string: album.coverBig) {
            coverView.sd_setImage(with: url)
        }
        
        if let artist = album.artist {
            artistLabel.text = artist.name
        } else {
            DeezerProvider.getAlbum(album.id) { responseAlbum in
                self.album = responseAlbum
                self.artistLabel.text = responseAlbum.artist?.name
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                alert.present(haptic: .error)
            }

        }
        
        self.album = album
        titleLabel.text = album.title
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
        explicitView.tintColor = SettingsManager.getColor.color
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let album,
              let delegate
        else { return }
        
        let shareAction = UIAction(title: MenuActionsEnum.shareLink.title, image: MenuActionsEnum.shareLink.image) {  _ in
            guard let artist = album.artist?.name else { return }
            
            let shareLink = "https://deezer.com/album/\(album.id)"
            SongLinkProvider().getShareLink(shareLink) { link in
                let text = Localization.MenuActions.ShareLink.shareMessage.rawValue.localizedWithParameters(title: album.title, artist: artist, link: link)
                let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                activityViewController.excludedActivityTypes = [.airDrop, .mail, .message]
                delegate.present(activityViewController)
            } failure: { error in
                let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                alertView.duration = 5
                alertView.present(haptic: .error)
            }

        }
        
        let shareMenu = UIMenu(options: .displayInline, children: [shareAction])
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(options: .displayInline, children: [shareMenu])
    }
    
}
