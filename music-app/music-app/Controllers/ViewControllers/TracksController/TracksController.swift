//
//  TracksController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.02.23.
//

import UIKit
import SPAlert

class TracksController: UIViewController {

    @IBOutlet weak var tracksTableView: UITableView!
    
    private var tracks = [DeezerTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracksTableView.dataSource = self
        tracksTableView.delegate = self
        tracksTableView.register(SongCell.self)
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

extension TracksController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nowPlayingVC = NowPlayingController()
        nowPlayingVC.modalPresentationStyle = .fullScreen
        nowPlayingVC.set(track: tracks[indexPath.row], playlist: tracks, indexInPlaylist: indexPath.row)
        nowPlayingVC.delegate = self
        present(nowPlayingVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let item = tracks[indexPath.row]
        guard let artist = item.artist else { return nil }
        
        return UIContextMenuConfiguration(actionProvider:  { suggestedActions in
            let showArtistAction = UIAction(title: MenuActionsEnum.showArtist.title, subtitle: artist.name, image: MenuActionsEnum.showArtist.image) { _ in
                DeezerProvider.getArtist(artist.id) { artist in
                    let artistVC = ArtistController()
                    artistVC.set(artist)
                    self.navigationController?.pushViewController(artistVC, animated: true)
                } failure: { error in
                    let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                    alert.present(haptic: .error)
                }
            }
            
            return UIMenu(options: .displayInline, children: [showArtistAction])
        })
    }
}

extension TracksController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
