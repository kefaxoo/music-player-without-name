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
    func reloadData() {
        tracks = RealmManager<LibraryTrack>().read().reversed()
        tracksTableView.reloadData()
    }
    
    func present(_ vc: UIActivityViewController) {
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
        DeezerProvider.getTrack(tracks[indexPath.row].id) { track in
            let nowPlayingVC = NowPlayingController()
            nowPlayingVC.modalPresentationStyle = .fullScreen
            track.localLink = self.tracks[indexPath.row].cacheLink
            nowPlayingVC.set(track: track)
            nowPlayingVC.delegate = self
            
            self.present(nowPlayingVC, animated: true)
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }
    }
}

extension LibrarySongsController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func present(_ vc: UIViewController) {
        present(vc, animated: true)
    }
}
