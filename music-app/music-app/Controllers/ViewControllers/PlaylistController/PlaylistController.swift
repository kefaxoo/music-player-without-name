//
//  PlaylistController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.03.23.
//

import UIKit
import SPAlert

class PlaylistController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var playlist: LibraryPlaylist?
    private var tracks = [LibraryTrackInPlaylist]()
    
    private lazy var createMenu: UIMenu? = {
        guard let playlist else { return nil }
        
        let actionsManager = ActionsManager()
        actionsManager.delegate = self
        guard let deletePlaylistAction = actionsManager.deletePlaylistFromLibraryAction(playlist) else { return nil }
        
        return UIMenu(options: .displayInline, children: [deletePlaylistAction])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(TrackInPlaylistCell.self, PlaylistInfoCell.self, TextPlaylistInfoCell.self)
        setupNavBar()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
        navigationController?.navigationBar.prefersLargeTitles = false
        
        guard let createMenu else { return }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: createMenu)
    }
    
    func set(_ playlist: LibraryPlaylist) {
        self.playlist = playlist
        tracks = RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == playlist.id })
    }

}

extension PlaylistController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var id: String {
            if indexPath.row == 0 {
                return PlaylistInfoCell.id
            } else if indexPath.row > 0, indexPath.row < tracks.count + 1 {
                return TrackInPlaylistCell.id
            } else {
                return TextPlaylistInfoCell.id
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        
        if indexPath.row == 0 {
            guard let playlistInfoCell = cell as? PlaylistInfoCell,
                  let playlist
            else { return cell }
            
            playlistInfoCell.set(playlist)
            return playlistInfoCell
        } else if indexPath.row > 0, indexPath.row < tracks.count + 1 {
            guard let trackCell = cell as? TrackInPlaylistCell else { return cell }
            
            trackCell.delegate = self
            trackCell.set(tracks[indexPath.row - 1])
            return trackCell
        } else {
            guard let textInfoCell = cell as? TextPlaylistInfoCell,
                  let playlist
            else { return cell }
            
            textInfoCell.set(playlist)
            return textInfoCell
        }
    }
}

extension PlaylistController: MenuActionsDelegate {
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        alert.present(haptic: haptic)
    }
    
    func popVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    func dismiss(_ alert: SPAlertView) {
        alert.dismiss()
    }
}
