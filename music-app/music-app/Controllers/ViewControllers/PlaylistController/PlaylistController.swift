//
//  PlaylistController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.03.23.
//

import UIKit
import SPAlert
import JDStatusBarNotification

class PlaylistController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
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
        tableView.delegate = self
        tableView.register(TrackInPlaylistCell.self, PlaylistInfoCell.self, TextPlaylistInfoCell.self)
        setInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setInterface()
    }
    
    private func setupNowPlayingView() {
        AudioPlayer.nowPlayingViewDelegate = self
        nowPlayingView.isHidden = !(AudioPlayer.currentTrack != nil)
        nowPlayingView.setInterface()
        nowPlayingView.playlist = playlist
        nowPlayingView.delegate = self
    }
    
    private func setInterface() {
        setupNavBar()
        setupNowPlayingView()
        self.tableView.reloadData()
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
            playlistInfoCell.audioPlayerDelegate = self
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
        guard let playlist else { return }
        
        self.tracks = RealmManager<LibraryTrackInPlaylist>().read().filter({ $0.playlistID == playlist.id })
        self.tableView.reloadData()
    }
    
    func dismiss(_ alert: SPAlertView) {
        alert.dismiss()
    }
    
    func present(_ vc: UIViewController) {
        self.present(vc, animated: true)
    }
    
    func present(_ vc: UIActivityViewController) {
        self.present(vc, animated: true)
    }
    
    func pushViewController(_ vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PlaylistController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0, indexPath.row < tracks.count + 1 {
            var playlist = [LibraryTrack]()
            tracks.forEach { track in
                playlist.append(LibraryTrack.getLibraryTrack(track))
            }
            
            AudioPlayer.set(track: playlist[indexPath.row - 1], playlist: playlist, indexInPlaylist: indexPath.row - 1)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row == 0 || indexPath.row > tracks.count {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let track = self.tracks[indexPath.row - 1]
            let actionsManager = ActionsManager()
            actionsManager.delegate = self
            var playlistSection = [UIAction]()
            guard let playlist = self.playlist,
                  let removeFromPlaylistAction = actionsManager.removeTrackFromPlaylist(track: track, playlistID: playlist.id)
            else { return nil }
            
            playlistSection.append(removeFromPlaylistAction)
            let playlistMenu = UIMenu(options: .displayInline, children: playlistSection)
            var librarySection = [UIAction]()
            if LibraryManager.isTrackInLibrary(track.id) {
                guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return nil }
                
                librarySection.append(removeFromLibraryAction)
                if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
                    let completion: () -> Void = {
                        self.tracks[indexPath.row - 1].cacheLink = ""
                    }
                    
                    guard let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track: LibraryTrack.getLibraryTrack(track), completion: completion) else { return nil }
                    
                    librarySection.append(removeTrackFromCacheAction)
                } else {
                    let completion: (String) -> Void = { cacheLink in
                        self.tracks[indexPath.row - 1].cacheLink = cacheLink
                    }
                    
                    guard let downloadTrackAction = actionsManager.downloadTrackAction(track: LibraryTrack.getLibraryTrack(track), completion: completion) else { return nil }
                    
                    librarySection.append(downloadTrackAction)
                }
            } else {
                guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return nil }
                
                librarySection.append(addToLibraryAction)
            }
            
            guard let addToPlaylistAction = actionsManager.addToPlaylistAction(LibraryTrack.getLibraryTrack(track)) else { return nil }
            
            librarySection.append(addToPlaylistAction)
            let libraryMenu = UIMenu(options: .displayInline, children: librarySection)
            guard let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track),
                  let shareSongAction = actionsManager.shareSongAction(track.id)
            else { return nil }
            
            let shareMenu = UIMenu(options: .displayInline, children: [shareLinkAction, shareSongAction])
            
            guard let showArtistAction = actionsManager.showArtistAction(track.artistID),
                  let showAlbumAction = actionsManager.showAlbumAction(id: track.albumID, title: track.albumTitle)
            else { return nil }
            
            let showMenu = UIMenu(options: .displayInline, children: [showArtistAction, showAlbumAction])
            
            return UIMenu(options: .displayInline, children: [playlistMenu, libraryMenu, shareMenu, showMenu])
        }
    }
}

extension PlaylistController: AudioPlayerDelegate {
    func setupView() {
        setupNowPlayingView()
    }
}
