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
        
        if let path = URL(string: playlist.image),
           let imageData = try? Data(contentsOf: path) {
            playlistImageView.image = UIImage(data: imageData)
        }
        
        playlistNameLabel.text = playlist.name
        explicitImageView.isHidden = !playlist.isExplicit
    }
    
    @IBAction func menuButtonAction(_ sender: Any) {
        guard let playlist,
              let delegate
        else { return }
        
        let deleteAction = UIAction(title: MenuActionsEnum.removePlaylistFromLibrary.rawValue, image: MenuActionsEnum.removePlaylistFromLibrary.image, attributes: .destructive) { _ in
            let tracksInPlaylist = RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == playlist.id })
            if !tracksInPlaylist.isEmpty {
                tracksInPlaylist.forEach { track in
                    RealmManager<LibraryTrackInPlaylist>().delete(object: track)
                }
            }
            
            try? FileManager.default.removeItem(atPath: playlist.image)
            RealmManager<LibraryPlaylist>().delete(object: playlist)
            let alertView = SPAlertView(title: "Success", preset: .done)
            alertView.present(haptic: .success)
            delegate.reloadData()
        }
        
        let deleteSection = UIMenu(options: .displayInline, children: [deleteAction])
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(options: .displayInline, children: [deleteSection])
    }
    
}
