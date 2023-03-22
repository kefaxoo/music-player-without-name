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
        nowPlayingView.delegate = self
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LibraryPlaylistsController: AudioPlayerDelegate {
    func setupView() {
        setupNowPlayingView()
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
