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
    
    private var albums = [DeezerAlbum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumsTableView.dataSource = self
        registerCell()
        getAlbums()
    }
    
    private func getAlbums() {
        let alertView = SPAlertView(title: "Loading albums", preset: .spinner)
        alertView.dismissByTap = false
        alertView.present()
        let tracks = RealmManager<LibraryTrack>().read()
        var albumsID = [Int]()
        tracks.forEach { track in
            albumsID.append(track.albumID)
        }
        
        albumsID = Array(Set(albumsID))
        albumsID.forEach { id in
            DeezerProvider().getAlbum(id) { album in
                self.albums.append(album)
                self.albums = self.albums.sorted { albumI, albumJ in
                    return albumI.title < albumJ.title
                }
                
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

extension LibraryAlbumsController: MenuActionsDelegate {
    func presentActivityController(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
}


