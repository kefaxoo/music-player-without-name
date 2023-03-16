//
//  ArtistController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit
import SPAlert

class ArtistController: UIViewController {
    
    @IBOutlet weak var artistTableView: UITableView!
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    private var artist: DeezerArtist?
    private var tracks = [DeezerTrack]()
    private var albums = [DeezerAlbum]()
    private var moreAlbums = [DeezerAlbum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistTableView.dataSource = self
        artistTableView.delegate = self
        artistTableView.register(ArtistInfoCell.self, TopTrackLabelCell.self, SongCell.self, MoreAlbumsByArtistCell.self)
    }
    
    private func setupNowPlayingView() {
        AudioPlayer.nowPlayingViewDelegate = self
        nowPlayingView.isHidden = !(AudioPlayer.currentTrack != nil)
        nowPlayingView.setInterface()
        nowPlayingView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        setupNowPlayingView()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func set(_ artist: DeezerArtist) {
        self.artist = artist
        DeezerProvider.getArtistTracks(artist.id) { tracks in
            self.tracks = tracks
            if self.artistTableView != nil {
                self.artistTableView.reloadData()
            }
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }
        
        DeezerProvider.getArtistAlbums(artist.id) { albums in
            self.albums = albums
            self.moreAlbums = albums.shuffled().suffix(8)
            if self.artistTableView != nil {
                self.artistTableView.reloadData()
            }
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }

    }
}

extension ArtistController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var id = ""
        if indexPath.row == 0 {
            id = ArtistInfoCell.id
        } else if indexPath.row == 1 {
            id = TopTrackLabelCell.id
        } else if indexPath.row > 1, indexPath.row <= tracks.count + 1 {
            id = SongCell.id
        } else {
            id = MoreAlbumsByArtistCell.id
        }
        
        let cell = artistTableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        if indexPath.row == 0 {
            guard let artistInfoCell = cell as? ArtistInfoCell,
                  let artist
            else { return cell }
            
            artistInfoCell.set(artist)
            return artistInfoCell
        } else if indexPath.row == 1 {
            guard let topTracksLabelCell = cell as? TopTrackLabelCell,
                  let artist
            else { return cell }
            
            topTracksLabelCell.set(artist)
            topTracksLabelCell.delegate = self
            return topTracksLabelCell
        } else if indexPath.row > 1, indexPath.row <= tracks.count + 1 {
            guard let songCell = cell as? SongCell else { return cell }
            
            songCell.set(track: tracks[indexPath.row - 2], isArtistController: true)
            songCell.delegate = self
            return songCell
        } else {
            guard let moreAlbumsCell = cell as? MoreAlbumsByArtistCell,
                  let artist
            else { return cell }
            
            moreAlbumsCell.set(albums: moreAlbums, artist: artist)
            moreAlbumsCell.setTextForButton(Localization.Controller.Artist.MoreAlbumsByArtistCell.title.rawValue.localized)
            moreAlbumsCell.delegate = self
            return moreAlbumsCell
        }
    }
}

extension ArtistController: MenuActionsDelegate {
    func present(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
    
    func reloadData() {
        artistTableView.reloadData()
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

extension ArtistController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArtistController: AudioPlayerDelegate {
    func setupView() {
        guard let currentTrack = AudioPlayer.currentTrack else { return }
        
        nowPlayingView.isHidden = false
        nowPlayingView.coverImageView.image = AudioPlayer.currentCover
        nowPlayingView.titleLabel.text = currentTrack.title
        nowPlayingView.artistLabel.text = currentTrack.artistName
        nowPlayingView.durationProgressView.progress = AudioPlayer.getDurationInFloat()
        if AudioPlayer.player.rate == 0 {
            nowPlayingView.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            nowPlayingView.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
}

extension ArtistController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 1, indexPath.row <= tracks.count + 1 {
            let index = indexPath.row - 2
            var tracks = [LibraryTrack]()
            self.tracks.forEach { trackInTable in
                guard let track = LibraryTrack.getLibraryTrack(trackInTable) else { return }
                
                tracks.append(track)
            }
            
            AudioPlayer.set(track: tracks[index], playlist: tracks, indexInPlaylist: index)
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.row < 2 || indexPath.row == 2 + tracks.count {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let trackIndex = indexPath.row - 2
            guard let track = LibraryTrack.getLibraryTrack(self.tracks[trackIndex]) else { return nil }
            
            let actionsManager = ActionsManager()
            actionsManager.delegate = self
            
            var librarySection = [UIAction]()
            if LibraryManager.isTrackInLibrary(track.id) {
                guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return nil }
                
                librarySection.append(removeFromLibraryAction)
                if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
                    guard let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track: track) else { return nil }
                    
                    librarySection.append(removeTrackFromCacheAction)
                } else {
                    guard let downloadTrackAction = actionsManager.downloadTrackAction(track: track) else { return nil }
                    
                    librarySection.append(downloadTrackAction)
                }
            } else {
                guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return nil }
                
                librarySection.append(addToLibraryAction)
            }
            
            guard let addToPlaylistAction = actionsManager.addToPlaylistAction(track) else { return nil }
            
            librarySection.append(addToPlaylistAction)
            let libraryMenu = UIMenu(options: .displayInline, children: librarySection)
            guard let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track),
                  let shareSongAction = actionsManager.shareSongAction(track.id)
            else { return nil }
            
            let shareMenu = UIMenu(options: .displayInline, children: [shareLinkAction, shareSongAction])
            
            guard let showAlbumAction = actionsManager.showAlbumAction(id: track.albumID, title: track.albumTitle) else { return nil }
            
            let showMenu = UIMenu(options: .displayInline, children: [showAlbumAction])
            
            let menuTrack = UIMenu(options: .displayInline, children: [libraryMenu, shareMenu,showMenu])
            return menuTrack
        }
    }
}
