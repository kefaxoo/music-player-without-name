//
//  LibrarySongsController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import UIKit
import SPAlert

class LibrarySongsController: UIViewController {

    @IBOutlet weak var tracksTableView: UITableView!
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    private let searchController = UISearchController()
    private var tracks = [LibraryTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracksTableView.dataSource = self
        tracksTableView.delegate = self
        tracksTableView.register(LibraryTrackCell.self)
        tracksTableView.reloadData()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
        tracksTableView.reloadData()
        if tracks.count != RealmManager<LibraryTrack>().read().count {
            if LibraryDataManager.Songs.alphabetSort {
                tracks = RealmManager<LibraryTrack>().read().sorted(by: { trackI, trackJ in
                    return trackI.title < trackJ.title
                })
            } else if LibraryDataManager.Songs.reversedAlphabetSort {
                tracks = RealmManager<LibraryTrack>().read().sorted(by: { trackI, trackJ in
                    return trackI.title > trackJ.title
                })
            } else {
                tracks = RealmManager<LibraryTrack>().read().reversed()
            }
            
            tracksTableView.reloadData()
        }
        
        setupNowPlayingView()
    }
    
    private func setupNowPlayingView() {
        AudioPlayer.nowPlayingViewDelegate = self
        nowPlayingView.isHidden = !(AudioPlayer.currentTrack != nil)
        nowPlayingView.setInterface()
        nowPlayingView.delegate = self
    }
    
    private func setTracks() {
        if LibraryDataManager.Songs.alphabetSort {
            tracks = RealmManager<LibraryTrack>().read().sorted(by: { trackI, trackJ in
                return trackI.title < trackJ.title
            })
        } else if LibraryDataManager.Songs.reversedAlphabetSort {
            tracks = RealmManager<LibraryTrack>().read().sorted(by: { trackI, trackJ in
                return trackI.title > trackJ.title
            })
        } else {
            tracks = RealmManager<LibraryTrack>().read().reversed()
        }
    }
    
    private func setupNavBar() {
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.tracks.rawValue.localized
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Localization.Controller.Library.Songs.SortButton.title.rawValue.localized, menu: createSortMenu())
    }
    
    private func createSortMenu() -> UIMenu {
        let sortByTitleAlphabetAction = UIAction(title: Localization.Controller.Library.Songs.SortButton.alphabet.rawValue.localized, state: LibraryDataManager.Songs.alphabetSort.getState) { _ in
            LibraryDataManager.Songs.alphabetSort = true
            LibraryDataManager.Songs.reversedAlphabetSort = false
            LibraryDataManager.Songs.recentlyAddedSort = false
            self.tracks = self.tracks.sorted(by: { trackI, trackJ in
                return trackI.title < trackJ.title
            })
            
            self.tracksTableView.reloadData()
        }
        
        let sortByTitleReverseAlphabetAction = UIAction(title: Localization.Controller.Library.Songs.SortButton.reversedAlphabet.rawValue.localized, state: LibraryDataManager.Songs.reversedAlphabetSort.getState) { _ in
            LibraryDataManager.Songs.alphabetSort = false
            LibraryDataManager.Songs.reversedAlphabetSort = true
            LibraryDataManager.Songs.recentlyAddedSort = false
            self.tracks = self.tracks.sorted(by: { trackI, trackJ in
                return trackI.title > trackJ.title
            })
            
            self.tracksTableView.reloadData()
        }
        
        let sortByDateAction = UIAction(title: Localization.Controller.Library.Songs.SortButton.recentlyAdded.rawValue.localized, state: LibraryDataManager.Songs.recentlyAddedSort.getState) { _ in
            LibraryDataManager.Songs.alphabetSort = false
            LibraryDataManager.Songs.reversedAlphabetSort = false
            LibraryDataManager.Songs.recentlyAddedSort = true
            self.tracks = RealmManager<LibraryTrack>().read().reversed()
            self.tracksTableView.reloadData()
        }
        
        return UIMenu(options: .singleSelection, children: [sortByTitleAlphabetAction, sortByTitleReverseAlphabetAction, sortByDateAction])
    }

}

extension LibrarySongsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tracksTableView.dequeueReusableCell(withIdentifier: LibraryTrackCell.id, for: indexPath)
        guard let trackCell = cell as? LibraryTrackCell else { return cell }
        
        trackCell.set(tracks[indexPath.row])
        trackCell.delegate = self
        return trackCell
    }
}

extension LibrarySongsController: MenuActionsDelegate {
    func present(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
    
    func reloadData() {
        setTracks()
        tracksTableView.reloadData()
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

extension LibrarySongsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tracks = RealmManager<LibraryTrack>().read().sorted(by: { trackI, trackJ in
            return trackI.title < trackJ.title
        })
        
        if !searchText.isEmpty {
            tracks = tracks.filter({ $0.title.lowercased().contains(searchText.lowercased()) })
        } else {
            if LibraryDataManager.Songs.alphabetSort {
                tracks = tracks.sorted(by: { trackI, trackJ in
                    return trackI.title < trackJ.title
                })
            } else if LibraryDataManager.Songs.reversedAlphabetSort {
                tracks = tracks.sorted(by: { trackI, trackJ in
                    return trackI.title > trackJ.title
                })
            } else if LibraryDataManager.Songs.recentlyAddedSort {
                tracks = tracks.reversed()
            }
        }
        
        tracksTableView.reloadData()
    }
}

extension LibrarySongsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AudioPlayer.set(track: tracks[indexPath.row], playlist: tracks, indexInPlaylist: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
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
            
            var showActions = [UIAction]()
            guard let showArtistAction = actionsManager.showArtistAction(track.artistID) else { return nil }
            
            showActions.append(showArtistAction)
            guard let showAlbumAction = actionsManager.showAlbumAction(track.albumID) else { return nil }
            
            showActions.append(showAlbumAction)
            let showMenu = UIMenu(options: .displayInline, children: showActions)
            
            return UIMenu(options: .displayInline, children: [libraryMenu, shareMenu, showMenu])
        }
    }
}

extension LibrarySongsController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibrarySongsController: AudioPlayerDelegate {
    func setupView() {
        setupNowPlayingView()
    }
}
