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
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    private var tracks = [DeezerTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tracksTableView.dataSource = self
        tracksTableView.delegate = self
        tracksTableView.register(SongCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = SettingsManager.getColor.color
        setupNowPlayingView()
    }
    
    private func setupNowPlayingView() {
        AudioPlayer.nowPlayingViewDelegate = self
        nowPlayingView.isHidden = !(AudioPlayer.currentTrack != nil)
        nowPlayingView.setInterface()
        nowPlayingView.delegate = self
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
        
        songCell.set(track: tracks[indexPath.row])
        songCell.delegate = self
        return songCell
    }
}

extension TracksController: MenuActionsDelegate {
    func present(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
    
    func reloadData() {
        tracksTableView.reloadData()
    }
    
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        alert.present(haptic: haptic)
    }
    
    func dismiss(_ alert: SPAlertView) {
        alert.dismiss()
    }
    
    func present(_ vc: UIViewController) {
        present(vc, animated: true)
    }
    
    func pushViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension TracksController: AudioPlayerDelegate {
    func setupView() {
        setupNowPlayingView()
    }
}

extension TracksController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tracksForPlayer = [LibraryTrack]()
        tracks.forEach { trackInTable in
            guard let track = LibraryTrack.getLibraryTrack(trackInTable) else { return }
            
            tracksForPlayer.append(track)
        }
        
        AudioPlayer.set(track: tracksForPlayer[indexPath.row], playlist: tracksForPlayer, indexInPlaylist: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: false)
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
