//
//  LibraryPlaylistCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 15.02.23.
//

import UIKit
import SPAlert

class LibraryPlaylistCell: UITableViewCell {

    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var explicitImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    
    static let id = String(describing: LibraryPlaylistCell.self)
    private var playlist: LibraryPlaylist?
    weak var delegate: MenuActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ playlist: LibraryPlaylist) {
        self.playlist = playlist
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let filePath = path?.appendingPathComponent(playlist.image),
           let imageData = try? Data(contentsOf: filePath) {
            playlistImageView.image = UIImage(data: imageData)
        }
        
        playlistNameLabel.text = playlist.name
        explicitImageView.isHidden = !playlist.isExplicit
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        let actionsManager = ActionsManager()
        actionsManager.delegate = self
        guard let playlist,
              let deletePlaylistAction = actionsManager.deletePlaylistFromLibraryAction(playlist)
        else { return }
        
        let deleteSection = UIMenu(options: .displayInline, children: [deletePlaylistAction])
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(options: .displayInline, children: [deleteSection])
    }
    
}

extension LibraryPlaylistCell: MenuActionsDelegate {
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        if let delegate {
            delegate.present(alert: alert, haptic: haptic)
        }
    }
    
    func reloadData() {
        if let delegate {
            delegate.reloadData()
        }
    }
}
