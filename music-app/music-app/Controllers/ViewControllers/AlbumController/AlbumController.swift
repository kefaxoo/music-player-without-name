//
//  AlbumController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit
import SPAlert

class AlbumController: UIViewController {

    @IBOutlet weak var albumTableView: UITableView!
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    private var album: DeezerAlbum?
    private var tracks = [DeezerTrack]()
    private var moreAlbums = [DeezerAlbum]()
    private var artist: DeezerArtist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumTableView.dataSource = self
        albumTableView.delegate = self
        albumTableView.register(AlbumInfoCell.self, AlbumTrackCell.self, TextAlbumInfoCell.self, MoreAlbumsByArtistCell.self)
        getInfo()
        getMoreAlbums()
        albumTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        albumTableView.reloadData()
        setupNavBar()
        setupNowPlayingView()
    }
    
    private func setupNowPlayingView() {
        AudioPlayer.nowPlayingViewDelegate = self
        nowPlayingView.isHidden = !(AudioPlayer.currentTrack != nil)
        nowPlayingView.setInterface()
        nowPlayingView.delegate = self
    }
    
    private func getInfo() {
        guard let albumID = album?.id else { return }
        
        DeezerProvider.getAlbum(albumID) { album in
            self.album = album
            guard let artistID = album.artist?.id else { return }
            DeezerProvider.getArtist(artistID) { artist in
                self.artist = artist
                self.getMoreAlbums()
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                alert.present(haptic: .error)
            }
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func set(_ album: DeezerAlbum) {
        self.album = album
        if let tracks = album.tracks?.data {
            self.tracks = tracks
        } else {
            DeezerProvider.getAlbum(album.id) { album in
                guard let tracks = album.tracks?.data else { return }
                    
                self.album = album
                self.tracks = tracks
                self.albumTableView.reloadData()
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                alert.present(haptic: .error)
            }

        }
        
        self.artist = album.artist
    }
    
    private func getMoreAlbums() {
        guard let artist else { return }
        
        DeezerProvider.getArtistAlbums(artist.id) { albums in
            self.moreAlbums = albums.filter({ $0.id != self.album?.id }).shuffled().suffix(8)
            self.albumTableView.reloadData()
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }

    }
}

extension AlbumController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + tracks.count + (moreAlbums.count > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = albumTableView.dequeueReusableCell(withIdentifier: AlbumInfoCell.id, for: indexPath)
            guard let albumInfoCell = cell as? AlbumInfoCell,
                  let album
            else { return cell }
            
            albumInfoCell.set(album)
            albumInfoCell.delegate = self
            return albumInfoCell
        } else if indexPath.row == 1 + tracks.count {
            let cell = albumTableView.dequeueReusableCell(withIdentifier: TextAlbumInfoCell.id, for: indexPath)
            guard let textAlbumInfoCell = cell as? TextAlbumInfoCell,
                  let album
            else { return cell }
            
            textAlbumInfoCell.set(album)
            return textAlbumInfoCell
        } else if indexPath.row == 2 + tracks.count, moreAlbums.count > 0 {
            let cell = albumTableView.dequeueReusableCell(withIdentifier: MoreAlbumsByArtistCell.id, for: indexPath)
            guard let moreAlbumsByArtistCell = cell as? MoreAlbumsByArtistCell,
                  let artist = album?.artist
            else { return cell }
            
            moreAlbumsByArtistCell.set(albums: moreAlbums, artist: artist)
            moreAlbumsByArtistCell.setTextForButton(Localization.Controller.Album.MoreAlbumsByArtistCell.moreByButton.rawValue.localizedWithParameters(artist: artist.name))
            moreAlbumsByArtistCell.delegate = self
            return moreAlbumsByArtistCell
        } else {
            let cell = albumTableView.dequeueReusableCell(withIdentifier: AlbumTrackCell.id, for: indexPath)
            guard let albumTrackCell = cell as? AlbumTrackCell else { return cell }
            
            albumTrackCell.set(tracks[indexPath.row - 1])
            albumTrackCell.delegate = self
            return albumTrackCell
        }
    }
}

extension AlbumController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AlbumController: MenuActionsDelegate {
    func reloadData() {
        albumTableView.reloadData()
    }
    
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        alert.present(haptic: haptic)
    }
    
    func dismiss(_ alert: SPAlertView) {
        alert.dismiss()
    }
    
    func present(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    func pushViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AlbumController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        var playlist = [LibraryTrack]()
        tracks.forEach { track in
            guard let libraryTrack = LibraryTrack.getLibraryTrack(track) else { return }
            
            playlist.append(libraryTrack)
        }
        
        if index > 0, index <= tracks.count {
            AudioPlayer.set(track: playlist[index - 1], playlist: playlist, indexInPlaylist: index - 1)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row == 0 || indexPath.row > tracks.count {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let track = self.tracks[indexPath.row - 1]
            
            guard let artist = track.artist?.name,
                  let album = track.album?.title
            else { return nil }
            
            let actionsManager = ActionsManager()
            actionsManager.delegate = self
            
            var libraryActions = [UIAction]()
            
            if LibraryManager.isTrackInLibrary(track.id) {
                guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return nil }
                
                libraryActions.append(removeFromLibraryAction)
                if LibraryManager.isTrackDownloaded(artist: artist, title: track.title, album: album) {
                    guard let libraryTrack = LibraryTrack.getLibraryTrack(track),
                          let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track: libraryTrack) else { return nil }
                    
                    libraryActions.append(removeTrackFromCacheAction)
                } else {
                    guard let libraryTrack = LibraryTrack.getLibraryTrack(track),
                          let downloadTrackAction = actionsManager.downloadTrackAction(track: libraryTrack) else { return nil }
                    
                    libraryActions.append(downloadTrackAction)
                }
            } else {
                guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return nil }
                
                libraryActions.append(addToLibraryAction)
            }
            
            guard let libraryTrack = LibraryTrack.getLibraryTrack(track),
                  let addToPlaylistAction = actionsManager.addToPlaylistAction(libraryTrack) else { return nil }
            
            libraryActions.append(addToPlaylistAction)
            
            let libraryActionsMenu = UIMenu(options: .displayInline, children: libraryActions)
            
            guard let shareSongAction = actionsManager.shareSongAction(track.id),
                  let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track)
            else { return nil }
            
            let shareActionsMenu = UIMenu(options: .displayInline, children: [shareSongAction, shareLinkAction])
            
            return UIMenu(children: [libraryActionsMenu, shareActionsMenu])
        }
    }
}

extension AlbumController: AudioPlayerDelegate {
    func setupView() {
        setupNowPlayingView()
    }
}
