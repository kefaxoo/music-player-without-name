//
//  LibrarySongsController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import UIKit

class LibrarySongsController: UIViewController {

    @IBOutlet weak var tracksTableView: UITableView!
    
    private let searchController = UISearchController()
    private var tracks = [LibraryTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracksTableView.dataSource = self
        registerCell()
        tracks = RealmManager<LibraryTrack>().read().reversed()
        tracksTableView.reloadData()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .purple
        tracks = RealmManager<LibraryTrack>().read().reversed()
        tracksTableView.reloadData()
    }
    
    private func setupNavBar() {
        searchController.searchBar.placeholder = "Type track name..."
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
