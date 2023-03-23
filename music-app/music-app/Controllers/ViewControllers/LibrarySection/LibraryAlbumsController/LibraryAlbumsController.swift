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
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    private let searchController = UISearchController()
    private var albums = [DeezerAlbum]()
    private var showedAlbums = [DeezerAlbum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumsTableView.dataSource = self
        albumsTableView.delegate = self
        albumsTableView.register(LibraryAlbumCell.self)
        getAlbums()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
        albumsTableView.reloadData()
        setupNowPlayingView()
    }
    
    private func setupNowPlayingView() {
        AudioPlayer.nowPlayingViewDelegate = self
        nowPlayingView.isHidden = !(AudioPlayer.currentTrack != nil)
        nowPlayingView.setInterface()
        nowPlayingView.delegate = self
    }
    
    private func setupNavBar() {
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.albums.rawValue.localized
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc private func hideKeyboard() {
        searchController.searchBar.endEditing(true)
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
    func reloadData() {
        albumsTableView.reloadData()
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let actionsManager = ActionsManager()
            actionsManager.delegate = self
            
            guard let shareAlbumAction = actionsManager.shareLinkAction(id: self.albums[indexPath.row].id, type: .album) else { return nil }
            
            return UIMenu(options: .displayInline, children: [shareAlbumAction])
        }
    }
}

extension LibraryAlbumsController: AudioPlayerDelegate {
    func setupView() {
        setupNowPlayingView()
    }
}
