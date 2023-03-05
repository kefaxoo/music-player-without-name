//
//  ArtistController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit
import SPAlert

class ArtistController: UIViewController {
    
    @IBOutlet weak var artistTableView: UITableView!
    
    private var artist: DeezerArtist?
    private var tracks = [DeezerTrack]()
    private var albums = [DeezerAlbum]()
    private var moreAlbums = [DeezerAlbum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistTableView.dataSource = self
        artistTableView.delegate = self
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = .systemPurple
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func registerCell() {
        var nib = UINib(nibName: ArtistInfoCell.id, bundle: nil)
        artistTableView.register(nib, forCellReuseIdentifier: ArtistInfoCell.id)
        nib = UINib(nibName: TopTrackLabelCell.id, bundle: nil)
        artistTableView.register(nib, forCellReuseIdentifier: TopTrackLabelCell.id)
        nib = UINib(nibName: SongCell.id, bundle: nil)
        artistTableView.register(nib, forCellReuseIdentifier: SongCell.id)
        nib = UINib(nibName: MoreAlbumsByArtistCell.id, bundle: nil)
        artistTableView.register(nib, forCellReuseIdentifier: MoreAlbumsByArtistCell.id)
    }
    
    func set(_ artist: DeezerArtist) {
        self.artist = artist
        DeezerProvider.getArtistTracks(artist.id) { tracks in
            self.tracks = tracks
            if self.artistTableView != nil {
                self.artistTableView.reloadData()
            }
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }
        
        DeezerProvider.getArtistAlbums(artist.id) { albums in
            self.albums = albums
            self.moreAlbums = albums.shuffled().suffix(8)
            if self.artistTableView != nil {
                self.artistTableView.reloadData()
            }
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }

    }
}

extension ArtistController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var id = ""
        if indexPath.row == 0 {
            id = ArtistInfoCell.id
        } else if indexPath.row == 1 {
            id = TopTrackLabelCell.id
        } else if indexPath.row > 1, indexPath.row <= tracks.count + 1 {
            id = SongCell.id
        } else {
            id = MoreAlbumsByArtistCell.id
        }
        
        let cell = artistTableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        if indexPath.row == 0 {
            guard let artistInfoCell = cell as? ArtistInfoCell,
                  let artist
            else { return cell }
            
            artistInfoCell.set(artist)
            return artistInfoCell
        } else if indexPath.row == 1 {
            guard let topTracksLabelCell = cell as? TopTrackLabelCell,
                  let artist
            else { return cell }
            
            topTracksLabelCell.set(artist)
            topTracksLabelCell.delegate = self
            return topTracksLabelCell
        } else if indexPath.row > 1, indexPath.row <= tracks.count + 1 {
            guard let songCell = cell as? SongCell else { return cell }
            
            songCell.set(tracks[indexPath.row - 2])
            songCell.delegate = self
            return songCell
        } else {
            guard let moreAlbumsCell = cell as? MoreAlbumsByArtistCell,
                  let artist
            else { return cell }
            
            moreAlbumsCell.set(albums: moreAlbums, artist: artist)
            moreAlbumsCell.setTextForButton(Localization.Controller.Artist.MoreAlbumsByArtistCell.title.rawValue.localized)
            moreAlbumsCell.delegate = self
            return moreAlbumsCell
        }
    }
}

extension ArtistController: MenuActionsDelegate {
    func presentActivityController(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
    
    func reloadData() {
        artistTableView.reloadData()
    }
}

extension ArtistController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArtistController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if index > 1, index <= tracks.count + 1 {
            let nowPlayingVC = NowPlayingController()
            nowPlayingVC.modalPresentationStyle = .fullScreen
            nowPlayingVC.set(track: tracks[index - 2], playlist: tracks, indexInPlaylist: index - 2)
            nowPlayingVC.delegate = self
            
            self.present(nowPlayingVC, animated: true)
        }
    }
}
