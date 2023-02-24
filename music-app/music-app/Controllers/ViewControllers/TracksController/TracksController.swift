//
//  TracksController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.02.23.
//

import UIKit

class TracksController: UIViewController {

    @IBOutlet weak var tracksTableView: UITableView!
    
    private var tracks = [DeezerTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracksTableView.dataSource = self
        registerCell()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: SongCell.id, bundle: nil)
        tracksTableView.register(nib, forCellReuseIdentifier: SongCell.id)
    }

    func set(_ tracks: [DeezerTrack]) {
        self.tracks = tracks
    }
    
}

extension TracksController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tracksTableView.dequeueReusableCell(withIdentifier: SongCell.id, for: indexPath)
        guard let songCell = cell as? SongCell else { return cell }
        
        songCell.set(tracks[indexPath.row])
        songCell.delegate = self
        return songCell
    }
}

extension TracksController: MenuActionsDelegate {
    func presentActivityController(_ vc: UIActivityViewController) {
        self.present(vc, animated: true)
    }
}
