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
    
    weak var delegate: MenuActionsDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .lightGray.withAlphaComponent(0.3)
        albumsCollectionView.dataSource = self
        albumsCollectionView.delegate = self
        albumsCollectionView.register(RecentlyAddedCell.self)
    }
    
    func setTextForButton(_ text: String) {
        moreButton.setTitle(text, for: .normal)
    }
    
    func set(albums: [DeezerAlbum], artist: DeezerArtist) {
        self.albums = albums
        self.artist = artist
        albumsCollectionView.reloadData()
    }
    
    @IBAction func moreAlbumsDidTap(_ sender: Any) {
        guard let artist,
              let delegate
        else { return }
        
        DeezerProvider.getArtistAlbums(artist.id) { albums in
            guard let title = self.moreButton.currentTitle else { return }
            
            let moreAlbumsVC = MoreAlbumsController()
            moreAlbumsVC.navigationItem.title = title
            moreAlbumsVC.set(albums)
            delegate.pushViewController(moreAlbumsVC)
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

extension MoreAlbumsByArtistCell: MenuActionsDelegate {
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        if let delegate {
            delegate.present(alert: alert, haptic: haptic)
        }
    }
    
    func popVC() {
        if let delegate {
            delegate.popVC()
        }
    }
    
    func reloadData() {
        if let delegate {
            delegate.reloadData()
        }
    }
    
    func dismiss(_ alert: SPAlertView) {
        if let delegate {
            delegate.dismiss(alert)
        }
    }
    
    func present(_ vc: UIViewController) {
        if let delegate {
            delegate.present(vc)
        }
    }
    
    func present(_ vc: UIActivityViewController) {
        if let delegate {
            delegate.present(vc)
        }
    }
    
    func pushViewController(_ vc: UIViewController) {
        if let delegate {
            delegate.pushViewController(vc)
        }
    }
}

extension MoreAlbumsByArtistCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate else { return }
        
        let albumVC = AlbumController()
        albumVC.set(albums[indexPath.row])
        delegate.pushViewController(albumVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let actionsManager = ActionsManager()
            actionsManager.delegate = self
            
            guard let indexPath = collectionView.indexPathForItem(at: point),
                  let shareAlbumAction = actionsManager.shareLinkAction(id: self.albums[indexPath.row].id, type: .album)
            else { return nil }
            
            return UIMenu(options: .displayInline, children: [shareAlbumAction])
        }
    }
}
