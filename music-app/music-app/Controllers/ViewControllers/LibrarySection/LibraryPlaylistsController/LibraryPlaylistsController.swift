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
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var playlists = [LibraryPlaylist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        playlistsTableView.dataSource = self
        playlistsTableView.delegate = self
        playlistsTableView.register(LibraryPlaylistCell.self)
        playlists = RealmManager<LibraryPlaylist>().read().reversed()
        playlistsTableView.reloadData()
        emptyInfoView.isHidden = !playlists.isEmpty
        emptyInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPlaylistAction)))
        setLocale()
    }
    
    private func setInterface() {
        emptyInfoView.tintColor = SettingsManager.getColor.color
    }
    
    private func setLocale() {
        descriptionLabel.text = Localization.Controller.Library.Playlists.desctiptionEmpty.rawValue.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playlists = RealmManager<LibraryPlaylist>().read().reversed()
        playlistsTableView.reloadData()
        emptyInfoView.isHidden = !playlists.isEmpty
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
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

extension LibraryPlaylistsController: MenuActionsDelegate {
    func reloadData() {
        playlists = RealmManager<LibraryPlaylist>().read()
        playlistsTableView.reloadData()
        emptyInfoView.isHidden = !playlists.isEmpty
    }
    
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        alert.present(haptic: haptic)
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
