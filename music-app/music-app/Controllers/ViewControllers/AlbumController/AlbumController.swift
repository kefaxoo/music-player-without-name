//
//  AlbumController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit
import SPAlert

class AlbumController: UIViewController {

    @IBOutlet weak var albumTableView: UITableView!
    
    private var album: DeezerAlbum?
    private var tracks = [DeezerTrack]()
    private var moreAlbums = [DeezerAlbum]()
    private var artist: DeezerArtist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumTableView.dataSource = self
        registerCells()
        getInfo()
        getMoreAlbums()
        albumTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    private func getInfo() {
        guard let albumID = album?.id else { return }
        
        DeezerProvider.getAlbum(albumID) { album in
            self.album = album
            guard let artistID = album.artist?.id else { return }
            DeezerProvider.getArtist(artistID) { artist in
                self.artist = artist
                self.getMoreAlbums()
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                alert.present(haptic: .error)
            }
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = .systemPurple
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func registerCells() {
        var nib = UINib(nibName: AlbumInfoCell.id, bundle: nil)
        albumTableView.register(nib, forCellReuseIdentifier: AlbumInfoCell.id)
        nib = UINib(nibName: AlbumTrackCell.id, bundle: nil)
        albumTableView.register(nib, forCellReuseIdentifier: AlbumTrackCell.id)
        nib = UINib(nibName: TextAlbumInfoCell.id, bundle: nil)
        albumTableView.register(nib, forCellReuseIdentifier: TextAlbumInfoCell.id)
        nib = UINib(nibName: MoreAlbumsByArtistCell.id, bundle: nil)
        albumTableView.register(nib, forCellReuseIdentifier: MoreAlbumsByArtistCell.id)
    }
    
    func set(_ album: DeezerAlbum) {
        self.album = album
        if let tracks = album.tracks?.data {
            self.tracks = tracks
        } else {
            DeezerProvider.getAlbum(album.id) { album in
                guard let tracks = album.tracks?.data else { return }
                    
                self.album = album
                self.tracks = tracks
                self.albumTableView.reloadData()
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                alert.present(haptic: .error)
            }

        }
        
        self.artist = album.artist
    }
    
    private func getMoreAlbums() {
        guard let artist else { return }
        
        DeezerProvider.getArtistAlbums(artist.id) { albums in
            self.moreAlbums = albums.filter({ $0.id != self.album?.id }).shuffled().suffix(8)
            self.albumTableView.reloadData()
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }

    }
}

extension AlbumController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + tracks.count + (moreAlbums.count > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = albumTableView.dequeueReusableCell(withIdentifier: AlbumInfoCell.id, for: indexPath)
            guard let albumInfoCell = cell as? AlbumInfoCell,
                  let album
            else { return cell }
            
            albumInfoCell.set(album)
            albumInfoCell.delegate = self
            return albumInfoCell
        } else if indexPath.row == 1 + tracks.count {
            let cell = albumTableView.dequeueReusableCell(withIdentifier: TextAlbumInfoCell.id, for: indexPath)
            guard let textAlbumInfoCell = cell as? TextAlbumInfoCell,
                  let album
            else { return cell }
            
            textAlbumInfoCell.set(album)
            return textAlbumInfoCell
        } else if indexPath.row == 2 + tracks.count, moreAlbums.count > 0 {
            let cell = albumTableView.dequeueReusableCell(withIdentifier: MoreAlbumsByArtistCell.id, for: indexPath)
            guard let moreAlbumsByArtistCell = cell as? MoreAlbumsByArtistCell,
                  let artist = album?.artist
            else { return cell }
            
            moreAlbumsByArtistCell.set(albums: moreAlbums, artist: artist)
            moreAlbumsByArtistCell.setTextForButton(Localization.Controller.Album.MoreAlbumsByArtistCell.moreByButton.rawValue.localizedWithParameters(artist: artist.name))
            moreAlbumsByArtistCell.delegate = self
            return moreAlbumsByArtistCell
        } else {
            let cell = albumTableView.dequeueReusableCell(withIdentifier: AlbumTrackCell.id, for: indexPath)
            guard let albumTrackCell = cell as? AlbumTrackCell else { return cell }
            
            albumTrackCell.set(tracks[indexPath.row - 1])
            albumTrackCell.delegate = self
            return albumTrackCell
        }
    }
}

extension AlbumController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AlbumController: MenuActionsDelegate {
    func reloadData() {
        albumTableView.reloadData()
    }
    
    func presentActivityController(_ vc: UIActivityViewController) {
        self.present(vc, animated: true)
    }
}
