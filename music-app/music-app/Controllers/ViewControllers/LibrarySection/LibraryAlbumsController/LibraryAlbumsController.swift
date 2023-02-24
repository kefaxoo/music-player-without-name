//
//  LibraryAlbumsController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 9.02.23.
//

import UIKit
import SPAlert

class LibraryAlbumsController: UIViewController {
    
    @IBOutlet weak var albumsTableView: UITableView!
    
    private let searchController = UISearchController()
    private var albums = [DeezerAlbum]()
    private var showedAlbums = [DeezerAlbum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumsTableView.dataSource = self
        albumsTableView.delegate = self
        registerCell()
        getAlbums()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .systemPurple
    }
    
    private func setupNavBar() {
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.albums.rawValue.localized
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    private func getAlbums() {
        let alertView = SPAlertView(title: Localization.Alert.Title.loadingAlbums.rawValue.localized, preset: .spinner)
        alertView.dismissByTap = false
        alertView.present()
        let tracks = RealmManager<LibraryTrack>().read()
        var albumsID = [Int]()
        tracks.forEach { track in
            albumsID.append(track.albumID)
        }
        
        albumsID = Array(Set(albumsID))
        albumsID.forEach { id in
            DeezerProvider.getAlbum(id) { album in
                self.albums.append(album)
                self.albums = self.albums.sorted { albumI, albumJ in
                    return albumI.title < albumJ.title
                }
                
                self.showedAlbums = self.albums
                self.albumsTableView.reloadData()
            } failure: { error in
                print(error)
            }
        }
        
        alertView.dismiss()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: LibraryAlbumCell.id, bundle: nil)
        albumsTableView.register(nib, forCellReuseIdentifier: LibraryAlbumCell.id)
    }
    
}

extension LibraryAlbumsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showedAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = albumsTableView.dequeueReusableCell(withIdentifier: LibraryAlbumCell.id, for: indexPath)
        guard let albumCell = cell as? LibraryAlbumCell else { return cell }
        
        albumCell.set(showedAlbums[indexPath.row])
        albumCell.delegate = self
        return albumCell
    }
}

extension LibraryAlbumsController: MenuActionsDelegate {
    func presentActivityController(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
}

extension LibraryAlbumsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            showedAlbums = albums.filter({ $0.title.lowercased().contains(searchText.lowercased()) }).sorted { albumI, albumJ in
                return albumI.title < albumJ.title
            }
        } else {
            showedAlbums = albums.sorted { albumI, albumJ in
                return albumI.title < albumJ.title
            }
        }
        
        albumsTableView.reloadData()
    }
}

extension LibraryAlbumsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumVC = AlbumController()
        albumVC.set(albums[indexPath.row])
        navigationController?.pushViewController(albumVC, animated: true)
    }
}
