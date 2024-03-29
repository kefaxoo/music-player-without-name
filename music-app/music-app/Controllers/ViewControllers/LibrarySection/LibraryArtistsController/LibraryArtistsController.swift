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
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    private let searchController = UISearchController()
    private var artists = [DeezerArtist]()
    private var showedArtists = [DeezerArtist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistsTableView.dataSource = self
        artistsTableView.delegate = self
        artistsTableView.register(LibraryArtistCell.self)
        getArtists()
        setupNavBar()
    }
    
    private func setupNowPlayingView() {
        AudioPlayer.nowPlayingViewDelegate = self
        nowPlayingView.isHidden = !(AudioPlayer.currentTrack != nil)
        nowPlayingView.setInterface()
        nowPlayingView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
        setupNowPlayingView()
    }
    
    private func setupNavBar() {
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.artists.rawValue.localized
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        searchController.searchBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc private func hideKeyboard() {
        searchController.searchBar.endEditing(true)
    }
    
    private func getArtists() {
        let alertView = SPAlertView(title: Localization.Alert.Title.loadingArtists.rawValue.localized, preset: .spinner)
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
            DeezerProvider.getArtist(id) { artist in
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
        getArtists()
        artistsTableView.reloadData()
    }
}

extension LibraryArtistsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            showedArtists = artists.filter({ $0.name.lowercased().contains(searchText.lowercased()) }).sorted { artistI, artistJ in
                return artistI.name < artistJ.name
            }
        } else {
            showedArtists = artists.sorted { artistI, artistJ in
                return artistI.name < artistJ.name
            }
        }
        
        artistsTableView.reloadData()
    }
}

extension LibraryArtistsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artistVC = ArtistController()
        artistVC.set(artists[indexPath.row])
        navigationController?.pushViewController(artistVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LibraryArtistsController: AudioPlayerDelegate {
    func setupView() {
        setupNowPlayingView()
    }
}
