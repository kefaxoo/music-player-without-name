//
//  LibraryController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 4.02.23.
//

import UIKit
import SPAlert

class LibraryController: UIViewController {
    
    @IBOutlet weak var navigationTableView: UITableView!
    @IBOutlet weak var recentlyAddedCollectionView: UICollectionView!
    @IBOutlet weak var recentlyAddedLabel: UILabel!
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    static let id = String(describing: LibraryController.self)
    
    private var tracks = [LibraryTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTableView.dataSource = self
        navigationTableView.delegate = self
        navigationTableView.register(LibraryCell.self)
        recentlyAddedCollectionView.dataSource = self
        recentlyAddedCollectionView.delegate = self
        recentlyAddedCollectionView.register(RecentlyAddedCell.self)
        tracks = RealmManager<LibraryTrack>().read().suffix(5).reversed()
        setLocale()
        nowPlayingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentNowPlayingVC)))
        setupNowPlayingView()
        LibraryManager.downloadArtworks()
    }
    
    @objc private func presentNowPlayingVC() {
        let nowPlayingVC = NowPlayingController()
        nowPlayingVC.delegate = self
        nowPlayingVC.set()
        nowPlayingVC.modalPresentationStyle = .fullScreen
        present(nowPlayingVC, animated: true)
    }
    
    private func setupNowPlayingView() {
        AudioPlayer.nowPlayingViewDelegate = self
        nowPlayingView.isHidden = !(AudioPlayer.currentTrack != nil)
        nowPlayingView.setInterface()
    }
    private func setLocale() {
        recentlyAddedLabel.text = Localization.Controller.Library.recentlyAddedLabel.rawValue.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tracks = RealmManager<LibraryTrack>().read().suffix(5).reversed()
        recentlyAddedCollectionView.reloadData()
        setupNowPlayingView()
        LibraryManager.downloadArtworks()
        navigationTableView.reloadData()
    }
    
}

extension LibraryController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = recentlyAddedCollectionView.dequeueReusableCell(withReuseIdentifier: RecentlyAddedCell.id, for: indexPath)
        guard let recentlyAddedCell = cell as? RecentlyAddedCell else { return cell }
        
        recentlyAddedCell.set(tracks[indexPath.row])
        return recentlyAddedCell
    }
}

extension LibraryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LibraryEnum.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = navigationTableView.dequeueReusableCell(withIdentifier: LibraryCell.id, for: indexPath)
        guard let libraryCell = cell as? LibraryCell else { return cell }
        
        libraryCell.set(LibraryEnum.allCases[indexPath.row])
        return libraryCell
    }
}

extension LibraryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = LibraryEnum.allCases[indexPath.row].vc
        vc.navigationItem.title = LibraryEnum.allCases[indexPath.row].name
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension LibraryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = SPAlertView(title: "", preset: .spinner)
        alert.dismissByTap = false
        alert.present()
        
        DeezerProvider.getAlbum(tracks[indexPath.row].albumID) { album in
            alert.dismiss()
            let albumVC = AlbumController()
            albumVC.set(album)
            self.navigationController?.pushViewController(albumVC, animated: true)
        } failure: { error in
            alert.dismiss()
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (suggestedActions) -> UIMenu? in
            guard let indexPath = collectionView.indexPathForItem(at: point) else { return nil }
            
            let track = self.tracks[indexPath.row]
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
            
            guard let showArtistAction = actionsManager.showArtistAction(track.artistID),
                  let showAlbumAction = actionsManager.showAlbumAction(id: track.albumID, title: track.albumTitle)
            else { return nil }
            
            let showMenu = UIMenu(options: .displayInline, children: [showArtistAction, showAlbumAction])
            
            return UIMenu(options: .displayInline, children: [libraryMenu, shareMenu, showMenu])
        }
    }
}

extension LibraryController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibraryController: AudioPlayerDelegate {
    func setupView() {
        setupNowPlayingView()
    }
}

extension LibraryController: MenuActionsDelegate {
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        alert.present(haptic: haptic)
    }
    
    func reloadData() {
        tracks = RealmManager<LibraryTrack>().read().suffix(5).reversed()
        LibraryManager.downloadArtworks()
        recentlyAddedCollectionView.reloadData()
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
