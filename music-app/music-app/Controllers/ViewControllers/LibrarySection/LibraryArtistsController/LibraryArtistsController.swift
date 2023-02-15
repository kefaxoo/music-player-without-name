//
//  LibraryArtistsController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 13.02.23.
//

import UIKit
import SPAlert

class LibraryArtistsController: UIViewController {

    @IBOutlet weak var artistsTableView: UITableView!
    
    private let searchController = UISearchController()
    private var artists = [DeezerArtist]()
    private var showedArtists = [DeezerArtist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistsTableView.dataSource = self
        registerCell()
        getArtists()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .purple
    }
    
    private func setupNavBar() {
        searchController.searchBar.placeholder = "Type artist name..."
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    private func getArtists() {
        let alertView = SPAlertView(title: "Loading artists", preset: .spinner)
        alertView.dismissByTap = false
        alertView.present()
        let tracks = RealmManager<LibraryTrack>().read()
        var artistsID = [Int]()
        tracks.forEach { track in
            artistsID.append(track.artistID)
        }
        
        artistsID = Array(Set(artistsID))
        artists.removeAll()
        artistsID.forEach { id in
            DeezerProvider().getArtist(id) { artist in
                self.artists.append(artist)
                self.artists = self.artists.sorted { artistI, artistJ in
                    return artistI.name < artistJ.name
                }
                
                self.showedArtists = self.artists
                self.artistsTableView.reloadData()
            } failure: { error in
                print(error)
            }
        }
        
        alertView.dismiss()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: LibraryArtistCell.id, bundle: nil)
        artistsTableView.register(nib, forCellReuseIdentifier: LibraryArtistCell.id)
    }
    
}

extension LibraryArtistsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showedArtists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = artistsTableView.dequeueReusableCell(withIdentifier: LibraryArtistCell.id, for: indexPath)
        guard let artistCell = cell as? LibraryArtistCell else { return cell }
        
        artistCell.set(showedArtists[indexPath.row])
        artistCell.delegate = self
        return artistCell
    }
}

extension LibraryArtistsController: MenuActionsDelegate {
    func presentActivityController(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
}

extension LibraryArtistsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            showedArtists = artists.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
        } else {
            showedArtists = artists
        }
        
        artistsTableView.reloadData()
    }
}
