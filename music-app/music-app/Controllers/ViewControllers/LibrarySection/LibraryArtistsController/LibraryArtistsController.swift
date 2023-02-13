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
    
    private var artists = [DeezerArtist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        artistsTableView.dataSource = self
        registerCell()
        getArtists()
    }
    
    private func getArtists() {
        let alertView = SPAlertView(title: "Loading artists", preset: .spinner)
        alertView.dismissByTap = false
        alertView.present()
        let tracks = RealmManager<LibraryTrack>().read()
        var artistsID = [Int]()
        tracks.forEach { track in
            artistsID.append(track.artistID)
        }
        
        artistsID = Array(Set(artistsID))
        artistsID.forEach { id in
            DeezerProvider().getArtist(id) { artist in
                self.artists.append(artist)
                self.artists = self.artists.sorted { artistI, artistJ in
                    return artistI.name < artistJ.name
                }
                
                self.artistsTableView.reloadData()
            } failure: { error in
                print(error)
            }
        }
        
        alertView.dismiss()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: LibraryArtistCell.id, bundle: nil)
        artistsTableView.register(nib, forCellReuseIdentifier: LibraryArtistCell.id)
    }
    
}

extension LibraryArtistsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = artistsTableView.dequeueReusableCell(withIdentifier: LibraryArtistCell.id, for: indexPath)
        guard let artistCell = cell as? LibraryArtistCell else { return cell }
        
        artistCell.set(artists[indexPath.row])
        artistCell.delegate = self
        return artistCell
    }
}

extension LibraryArtistsController: MenuActionsDelegate {
    func presentActivityController(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
}
