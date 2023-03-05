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
        registerCell()
        tracks = RealmManager<LibraryTrack>().read().reversed()
        tracksTableView.reloadData()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .systemPurple
        if tracks.count != RealmManager<LibraryTrack>().read().count {
            tracks = RealmManager<LibraryTrack>().read().reversed()
            tracksTableView.reloadData()
        }
    }
    
    private func setupNavBar() {
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.tracks.rawValue.localized
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    private func registerCell() {
        let nib = UINib(nibName: LibraryTrackCell.id, bundle: nil)
        tracksTableView.register(nib, forCellReuseIdentifier: LibraryTrackCell.id)
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
    
    func presentActivityController(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
    
    func pushViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibrarySongsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tracks = RealmManager<LibraryTrack>().read()
        if !searchText.isEmpty {
            tracks = tracks.filter({ $0.title.lowercased().contains(searchText.lowercased()) })
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
}
