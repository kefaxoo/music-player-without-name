//
//  LibraryController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 4.02.23.
//

import UIKit
import SPAlert

class LibraryController: UIViewController {

    @IBOutlet weak var navigationTableView: UITableView!
    @IBOutlet weak var recentlyAddedCollectionView: UICollectionView!
    @IBOutlet weak var recentlyAddedLabel: UILabel!
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    static let id = String(describing: LibraryController.self)
    
    private var tracks = [LibraryTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTableView.dataSource = self
        navigationTableView.delegate = self
        navigationTableView.register(LibraryCell.self)
        recentlyAddedCollectionView.dataSource = self
        recentlyAddedCollectionView.delegate = self
        recentlyAddedCollectionView.register(RecentlyAddedCell.self)
        tracks = RealmManager<LibraryTrack>().read().suffix(5).reversed()
        setLocale()
        nowPlayingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentNowPlayingVC)))
        setupNowPlayingView()
        LibraryManager.downloadArtworks()
    }
    
    @objc private func presentNowPlayingVC() {
        let nowPlayingVC = NowPlayingController()
        nowPlayingVC.delegate = self
        nowPlayingVC.set()
        nowPlayingVC.modalPresentationStyle = .fullScreen
        present(nowPlayingVC, animated: true)
    }
    
    private func setupNowPlayingView() {
//        if AudioPlayer.currentTrack != nil {
//            nowPlayingView.isHidden = false
//            nowPlayingView.set()
//        } else {
//            nowPlayingView.isHidden = true
//        }
    }
    
    private func setLocale() {
        recentlyAddedLabel.text = Localization.Controller.Library.recentlyAddedLabel.rawValue.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tracks = RealmManager<LibraryTrack>().read().suffix(5).reversed()
        recentlyAddedCollectionView.reloadData()
        setupNowPlayingView()
        LibraryManager.downloadArtworks()
    }

}

extension LibraryController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = recentlyAddedCollectionView.dequeueReusableCell(withReuseIdentifier: RecentlyAddedCell.id, for: indexPath)
        guard let recentlyAddedCell = cell as? RecentlyAddedCell else { return cell }
        
        recentlyAddedCell.set(tracks[indexPath.row])
        return recentlyAddedCell
    }
}

extension LibraryController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LibraryEnum.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = navigationTableView.dequeueReusableCell(withIdentifier: LibraryCell.id, for: indexPath)
        guard let libraryCell = cell as? LibraryCell else { return cell }
        
        libraryCell.set(LibraryEnum.allCases[indexPath.row])
        return libraryCell
    }
}

extension LibraryController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = LibraryEnum.allCases[indexPath.row].vc
        vc.navigationItem.title = LibraryEnum.allCases[indexPath.row].name
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LibraryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DeezerProvider.getAlbum(tracks[indexPath.row].albumID) { album in
            let albumVC = AlbumController()
            albumVC.set(album)
            self.navigationController?.pushViewController(albumVC, animated: true)
        } failure: { error in
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }
    }
}

extension LibraryController: ViewControllerDelegate {
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
