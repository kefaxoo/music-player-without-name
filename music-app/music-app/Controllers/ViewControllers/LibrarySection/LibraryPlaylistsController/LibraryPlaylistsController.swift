//
//  LibraryPlaylistsController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 15.02.23.
//

import UIKit
import SPAlert

class LibraryPlaylistsController: UIViewController {

    @IBOutlet weak var playlistsTableView: UITableView!
    @IBOutlet weak var emptyInfoView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var playlists = [LibraryPlaylist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        playlistsTableView.dataSource = self
        playlistsTableView.delegate = self
        playlistsTableView.register(LibraryPlaylistCell.self)
        emptyInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPlaylistAction)))
        setInterface()
    }
    
    private func setupNowPlayingView() {
        AudioPlayer.nowPlayingViewDelegate = self
        nowPlayingView.isHidden = !(AudioPlayer.currentTrack != nil)
        nowPlayingView.setInterface()
        let interaction = UIContextMenuInteraction(delegate: self)
        nowPlayingView.addInteraction(interaction)
    }
    
    private func setInterface() {
        setLocale()
        setupNowPlayingView()
        emptyImageView.tintColor = SettingsManager.getColor.color
        emptyInfoView.isHidden = !playlists.isEmpty
        playlists = RealmManager<LibraryPlaylist>().read().reversed()
        playlistsTableView.reloadData()
    }
    
    private func setLocale() {
        descriptionLabel.text = Localization.Controller.Library.Playlists.desctiptionEmpty.rawValue.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
        setInterface()
    }
    
    private func setupNavBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Localization.Controller.Library.Playlists.navBarButton.rawValue.localized, style: .plain, target: self, action: #selector(addPlaylistAction))
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.playlists.rawValue.localized
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }

    @objc private func addPlaylistAction() {
        let addPlaylistVC = AddPlaylistController()
        addPlaylistVC.reloadClosure = {
            self.playlists = RealmManager<LibraryPlaylist>().read()
            self.playlistsTableView.reloadData()
            self.emptyInfoView.isHidden = !self.playlists.isEmpty
        }
        
        if let presentController = addPlaylistVC.presentationController as? UISheetPresentationController {
            presentController.detents = [.medium(), .large()]
        }
        
        present(addPlaylistVC, animated: true)
    }
}

extension LibraryPlaylistsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playlistsTableView.dequeueReusableCell(withIdentifier: LibraryPlaylistCell.id, for: indexPath)
        guard let playlistCell = cell as? LibraryPlaylistCell else { return cell }
        
        playlistCell.set(playlists[indexPath.row])
        playlistCell.delegate = self
        return playlistCell
    }
}

extension LibraryPlaylistsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        playlists = RealmManager<LibraryPlaylist>().read().reversed()
        if !searchText.isEmpty {
            playlists = playlists.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
        }
        
        playlistsTableView.reloadData()
    }
}

extension LibraryPlaylistsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlistVC = PlaylistController()
        playlistVC.set(playlists[indexPath.row])
        navigationController?.pushViewController(playlistVC, animated: true)
    }
}

extension LibraryPlaylistsController: AudioPlayerDelegate {
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

extension LibraryPlaylistsController: MenuActionsDelegate {
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        alert.present(haptic: haptic)
    }
    
    func popVC() {
        self.navigationController?.popViewController(animated: true)
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
    
    func reloadData() {
        playlists = RealmManager<LibraryPlaylist>().read().reversed()
        playlistsTableView.reloadData()
        emptyInfoView.isHidden = !playlists.isEmpty
    }
}

extension LibraryPlaylistsController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            guard let track = AudioPlayer.currentTrack else { return UIMenu() }
            
            let actionsManager = ActionsManager()
            actionsManager.delegate = self
            var librarySection = [UIAction]()
            if LibraryManager.isTrackInLibrary(track.id) {
                guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return UIMenu() }
                
                librarySection.append(removeFromLibraryAction)
                if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
                    guard let removeTrackFromCacheAction = actionsManager.deleteTrackFromCacheAction(track: track) else { return UIMenu() }
                    
                    librarySection.append(removeTrackFromCacheAction)
                } else {
                    guard let downloadTrackAction = actionsManager.downloadTrackAction(track: track) else { return UIMenu() }
                    
                    librarySection.append(downloadTrackAction)
                }
            } else {
                guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return UIMenu() }
                
                librarySection.append(addToLibraryAction)
            }
            
            guard let addToPlaylistAction = actionsManager.addToPlaylistAction(track) else { return UIMenu() }
            
            librarySection.append(addToPlaylistAction)
            let libraryMenu = UIMenu(options: .displayInline, children: librarySection)
            guard let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track),
                  let shareSongAction = actionsManager.shareSongAction(track.id)
            else { return UIMenu() }
            
            let shareMenu = UIMenu(options: .displayInline, children: [shareLinkAction, shareSongAction])
            
            guard let showArtistAction = actionsManager.showArtistAction(track.artistID),
                  let showAlbumAction = actionsManager.showAlbumAction(id: track.albumID, title: track.albumTitle)
            else { return UIMenu() }
            
            let showMenu = UIMenu(options: .displayInline, children: [showArtistAction, showAlbumAction])
            
            return UIMenu(options: .displayInline, children: [libraryMenu, shareMenu, showMenu])
        }
    }
}
