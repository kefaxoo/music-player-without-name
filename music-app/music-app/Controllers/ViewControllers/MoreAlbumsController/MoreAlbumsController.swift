//
//  MoreAlbumsController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit

class MoreAlbumsController: UIViewController {

    @IBOutlet weak var albumsTableView: UITableView!
    
    private var albums = [DeezerAlbum]()
    private var artist = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumsTableView.dataSource = self
        albumsTableView.delegate = self
        registerCell()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: LibraryAlbumCell.id, bundle: nil)
        albumsTableView.register(nib, forCellReuseIdentifier: LibraryAlbumCell.id)
    }
    
    func set(_ albums: [DeezerAlbum]) {
        self.albums = albums
    }

}

extension MoreAlbumsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = albumsTableView.dequeueReusableCell(withIdentifier: LibraryAlbumCell.id, for: indexPath)
        guard let albumCell = cell as? LibraryAlbumCell else { return cell }
        
        albumCell.set(albums[indexPath.row])
        albumCell.delegate = self
        return albumCell
    }
}

extension MoreAlbumsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let albumVC = AlbumController()
        albumVC.set(albums[indexPath.row])
        navigationController?.pushViewController(albumVC, animated: true)
    }
}

extension MoreAlbumsController: MenuActionsDelegate {
    func presentActivityController(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
}
