//
//  SearchController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 4.02.23.
//

import UIKit
import SPAlert

class SearchController: UIViewController {

    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var resultTableView: UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    static let id = String(describing: SearchController.self)
    
    private var result = [Any]()
    private var query = ""
    private var request: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchController()
        resultTableView.dataSource = self
        resultTableView.delegate = self
        resultTableView.register(SongCell.self, LibraryArtistCell.self, LibraryAlbumCell.self)
        setLocale()
        showTop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
    }
    
    private func setLocale() {
        typeSegmentedControl.setTitle(Localization.Controller.Search.segmentedControl.tracks.rawValue.localized, forSegmentAt: 0)
        typeSegmentedControl.setTitle(Localization.Controller.Search.segmentedControl.artists.rawValue.localized, forSegmentAt: 1)
        typeSegmentedControl.setTitle(Localization.Controller.Search.segmentedControl.albums.rawValue.localized, forSegmentAt: 2)
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.main.rawValue.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultTableView.reloadData()
    }
    
    private func getResult() {
        switch typeSegmentedControl.selectedSegmentIndex {
            case 0:
                showTracks(query)
            case 1:
                showArtists(query)
            case 2:
                showAlbums(query)
            default:
                return
        }
    }
    
    private func setSearchController() {
        searchController.searchBar.placeholder = Localization.SearchBarPlaceholder.main.rawValue.localized
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    @IBAction func typeDidChange(_ sender: Any) {
        getResult()
    }
}

extension SearchController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id: String = {
            switch typeSegmentedControl.selectedSegmentIndex {
                case 0:
                    return SongCell.id
                case 1:
                    return LibraryArtistCell.id
                case 2:
                    return LibraryAlbumCell.id
                default:
                    return ""
            }
        }()
        
        let cell = resultTableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        
        switch typeSegmentedControl.selectedSegmentIndex {
            case 0:
                guard let trackCell = cell as? SongCell,
                      let result = result[indexPath.row] as? DeezerTrack else { return cell }
                
                trackCell.set(result)
                trackCell.delegate = self
                return trackCell
            case 1:
                guard let artistCell = cell as? LibraryArtistCell,
                      let result = result[indexPath.row] as? DeezerArtist else { return cell }
                
                artistCell.set(result)
                return artistCell
            case 2:
                guard let albumCell = cell as? LibraryAlbumCell,
                      let result = result[indexPath.row] as? DeezerAlbum else { return cell }
                
                albumCell.set(result)
                albumCell.delegate = self
                return albumCell
            default:
                return cell
        }
    }
}

// MARK: Requests extension

extension SearchController {
    private func showTop() {
        DeezerProvider.getTopTracks { tracks in
            self.result = tracks
            self.resultTableView.reloadData()
        } failure: { error in
            let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: error, preset: .error)
            alertView.present(haptic: .error) {
                self.searchController.searchBar.text = ""
            }
        }
    }
    
    private func showTracks(_ query: String) {
        DeezerProvider.findTracks(queryParameter: query) { tracks in
            self.result = tracks
            self.resultTableView.reloadData()
        } failure: { error in
            let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: error, preset: .error)
            alertView.present(haptic: .error) {
                self.searchController.searchBar.text = ""
            }
        }
    }
    
    private func showArtists(_ query: String) {
        DeezerProvider.findArtists(queryParameter: query) { artists in
            self.result = artists
            self.resultTableView.reloadData()
        } failure: { error in
            let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: error, preset: .error)
            alertView.present(haptic: .error) {
                self.searchController.searchBar.text = ""
            }
        }
    }
    
    private func showAlbums(_ query: String) {
        DeezerProvider.findAlbums(queryParameter: query) { albums in
            self.result = albums
            self.resultTableView.reloadData()
        } failure: { error in
            let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: error, preset: .error)
            alertView.present(haptic: .error) {
                self.searchController.searchBar.text = ""
            }
        }
    }
}

extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        UIView.animate(withDuration: 0.5) {
            self.typeSegmentedControl.isHidden = searchText.isEmpty
        }

        query = searchText
        if searchText.isEmpty {
            showTop()
        } else {
            getResult()
        }
    }
}

extension SearchController: MenuActionsDelegate {
    func reloadData() {
        resultTableView.reloadData()
    }
    
    func presentActivityController(_ vc: UIActivityViewController) {
        self.present(vc, animated: true)
    }
    
    func pushViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch typeSegmentedControl.selectedSegmentIndex {
            case 0:
                guard let tracks = result as? [DeezerTrack] else { return }
                
                let nowPlayingVC = NowPlayingController()
                nowPlayingVC.modalPresentationStyle = .fullScreen
                nowPlayingVC.set(track: tracks[indexPath.row], playlist: tracks, indexInPlaylist: indexPath.row)
                nowPlayingVC.delegate = self
                
                self.present(nowPlayingVC, animated: true)
            case 1:
                guard let artist = result[indexPath.row] as? DeezerArtist else { return }
                
                let artistVC = ArtistController()
                artistVC.set(artist)
                navigationController?.pushViewController(artistVC, animated: true)
            case 2:
                guard let album = result[indexPath.row] as? DeezerAlbum else { return }
                
                let albumVC = AlbumController()
                albumVC.set(album)
                navigationController?.pushViewController(albumVC, animated: true)
            default:
                break
        }
    }
}

extension SearchController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
