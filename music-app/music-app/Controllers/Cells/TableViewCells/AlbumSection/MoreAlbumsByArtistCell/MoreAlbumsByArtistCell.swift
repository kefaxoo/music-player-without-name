//
//  MoreAlbumsByArtistCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit
import SPAlert

class MoreAlbumsByArtistCell: UITableViewCell {

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    
    static let id = String(describing: MoreAlbumsByArtistCell.self)
    
    private var artist: DeezerArtist?
    private var albums = [DeezerAlbum]()
    
    weak var delegate: ViewControllerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .lightGray.withAlphaComponent(0.3)
        albumsCollectionView.dataSource = self
        albumsCollectionView.delegate = self
        registerCell()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: RecentlyAddedCell.id, bundle: nil)
        albumsCollectionView.register(nib, forCellWithReuseIdentifier: RecentlyAddedCell.id)
    }
    
    func set(albums: [DeezerAlbum], artist: DeezerArtist) {
        self.albums = albums
        self.artist = artist
        moreButton.setTitle("More by \(artist.name)", for: .normal)
        albumsCollectionView.reloadData()
    }
    
    @IBAction func moreAlbumsDidTap(_ sender: Any) {
        guard let artist,
              let delegate
        else { return }
        
        DeezerProvider.getArtistAlbums(artist.id) { albums in
            let moreAlbumsVC = MoreAlbumsController()
            moreAlbumsVC.navigationItem.title = "More by \(artist.name)"
            moreAlbumsVC.set(albums)
            delegate.pushVC(moreAlbumsVC)
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }
    }
}

extension MoreAlbumsByArtistCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumsCollectionView.dequeueReusableCell(withReuseIdentifier: RecentlyAddedCell.id, for: indexPath)
        guard let albumCell = cell as? RecentlyAddedCell,
              let artist
        else { return cell }
        
        albumCell.set(albums[indexPath.row], artist.name)
        return albumCell
    }
}

extension MoreAlbumsByArtistCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate else { return }
        
        let albumVC = AlbumController()
        albumVC.set(albums[indexPath.row])
        delegate.pushVC(albumVC)
    }
}
