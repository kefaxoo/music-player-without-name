//
//  LibraryController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 4.02.23.
//

import UIKit

class LibraryController: UIViewController {

    @IBOutlet weak var navigationTableView: UITableView!
    @IBOutlet weak var recentlyAddedCollectionView: UICollectionView!
    
    static let id = String(describing: LibraryController.self)
    
    private var tracks = [LibraryTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTableView.dataSource = self
        navigationTableView.delegate = self
        recentlyAddedCollectionView.dataSource = self
        registerCells()
        tracks = RealmManager<LibraryTrack>().read().reversed().suffix(5)
        print(tracks.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tracks = RealmManager<LibraryTrack>().read().reversed().suffix(5)
        print(tracks.count)
        recentlyAddedCollectionView.reloadData()
    }
    
    private func registerCells() {
        var nib = UINib(nibName: LibraryCell.id, bundle: nil)
        navigationTableView.register(nib, forCellReuseIdentifier: LibraryCell.id)
        nib = UINib(nibName: RecentlyAddedCell.id, bundle: nil)
        recentlyAddedCollectionView.register(nib, forCellWithReuseIdentifier: RecentlyAddedCell.id)
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
