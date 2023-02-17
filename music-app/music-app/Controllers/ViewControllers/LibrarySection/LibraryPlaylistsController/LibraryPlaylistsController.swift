//
//  LibraryPlaylistsController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 15.02.23.
//

import UIKit

class LibraryPlaylistsController: UIViewController {

    @IBOutlet weak var playlistsTableView: UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var playlists = [LibraryPlaylist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        playlistsTableView.dataSource = self
        registerCell()
        playlists = RealmManager<LibraryPlaylist>().read()
        playlistsTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .purple
    }
    
    private func setupNavBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Localization.Controller.Library.Playlists.navBarButton.rawValue.localized, style: .plain, target: self, action: #selector(addPlaylistAction))
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.playlists.rawValue.localized
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    private func registerCell() {
        let nib = UINib(nibName: LibraryPlaylistCell.id, bundle: nil)
        playlistsTableView.register(nib, forCellReuseIdentifier: LibraryPlaylistCell.id)
    }

    @objc private func addPlaylistAction() {
        let addPlaylistVC = AddPlaylistController()
        addPlaylistVC.reloadClosure = {
            self.playlists = RealmManager<LibraryPlaylist>().read()
            self.playlistsTableView.reloadData()
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
    }
}

extension LibraryPlaylistsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        playlists = RealmManager<LibraryPlaylist>().read()
        if !searchText.isEmpty {
            playlists = playlists.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
        }
        
        playlistsTableView.reloadData()
    }
}
