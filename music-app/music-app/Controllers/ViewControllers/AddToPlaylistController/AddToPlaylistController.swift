//
//  AddToPlaylistController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.03.23.
//

import UIKit
import SPAlert

class AddToPlaylistController: UIViewController {

    @IBOutlet weak var playlistsTableView: UITableView!

    private var playlists = [LibraryPlaylist]()
    private let searchController = UISearchController()
    private var libraryTrack: LibraryTrack?
    private var onlineTrack: DeezerTrack?
    
    weak var delegate: MenuActionsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlistsTableView.dataSource = self
        playlistsTableView.delegate = self
        playlistsTableView.register(PlaylistCell.self)
        playlists = RealmManager<LibraryPlaylist>().read().reversed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.playlists.rawValue.localized
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        navigationItem.title = Localization.MenuActions.addToPlaylist.rawValue.localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Localization.Controller.Library.AddToPlaylist.cancelButton.rawValue.localized, style: .plain, target: self, action: #selector(cancelButtonDidTap))
    }
    
    @objc private func hideKeyboard() {
        searchController.searchBar.endEditing(true)
    }
    
    @objc private func cancelButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    func set(_ track: LibraryTrack) {
        libraryTrack = track
    }
    
    func set(_ track: DeezerTrack) {
        onlineTrack = track
    }
}

extension AddToPlaylistController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistsTableView.dequeueReusableCell(withIdentifier: PlaylistCell.id, for: indexPath)
        guard let playlistCell = cell as? PlaylistCell else { return cell }
        
        playlistCell.set(playlists[indexPath.row])
        return playlistCell
    }
}

extension AddToPlaylistController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        playlists = RealmManager<LibraryPlaylist>().read().reversed()
        
        if !searchText.isEmpty {
            playlists = playlists.filter({ $0.name.contains(searchText) })
        }
        
        playlistsTableView.reloadData()
    }
}

extension AddToPlaylistController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate else { return }
        
        if let track = libraryTrack {
            let actionManager = ActionsManager()
            actionManager.delegate = self
            
            if LibraryManager.isTrackInPlaylist(trackID: track.id, playlistID: playlists[indexPath.row].id) {
                let alert = UIAlertController(title: Localization.Alert.Title.trackInPlaylist.rawValue.localized, message: Localization.Alert.Message.trackInPlaylist.rawValue.localized, preferredStyle: .alert)
                
                guard let addSongToPlaylistAction = actionManager.addSongToPlaylistAction(track: track, playlist: playlists[indexPath.row]),
                      let skipAddingAction = actionManager.cancelAddingSongToPlaylistAction
                else { return }
                
                alert.addAction(addSongToPlaylistAction)
                alert.addAction(skipAddingAction)
                alert.preferredAction = skipAddingAction
                self.present(alert, animated: true)
            } else {
                let newTrack = LibraryTrackInPlaylist(id: track.id, title: track.title, duration: track.duration, trackPosition: track.trackPosition, diskNumber: track.diskNumber, isExplicit: track.isExplicit, artistID: track.artistID, artistName: track.artistName, albumID: track.albumID, albumName: track.albumTitle, onlineLink: track.onlineLink, cacheLink: track.cacheLink, coverLink: track.coverLink, playlistID: playlists[indexPath.row].id)
                RealmManager<LibraryTrackInPlaylist>().write(object: newTrack)
                
                playlists[indexPath.row].updateIsExplicit()
                let alert = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
                alert.present(haptic: .success)
                delegate.reloadData()
                self.dismiss()
            }
        } else if let track = onlineTrack {
            let trackPosition = track.trackPosition ?? 0
            let diskNumber = track.diskNumber ?? 0
            guard let artist = track.artist,
                  let album = track.album
            else { return }
            
            let newTrackInPlaylist = LibraryTrackInPlaylist(id: track.id, title: track.title, duration: track.duration, trackPosition: trackPosition, diskNumber: diskNumber, isExplicit: track.isExplicit, artistID: artist.id, artistName: artist.name, albumID: album.id, albumName: album.title, onlineLink: track.downloadLink, cacheLink: "", coverLink: "", playlistID: playlists[indexPath.row].id)
            RealmManager<LibraryTrackInPlaylist>().write(object: newTrackInPlaylist)
        }
    }
}

extension AddToPlaylistController: MenuActionsDelegate {
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        alert.present(haptic: haptic)
    }
    
    func dismiss() {
        self.dismiss(animated: true)
    }
}
