//
//  SearchController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 4.02.23.
//

import UIKit
import SPAlert

class SearchController: UIViewController {

    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var resultTableView: UITableView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    static let id = String(describing: SearchController.self)
    
    private var result = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchController()
        searchController.searchBar.delegate = self
        resultTableView.dataSource = self
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultTableView.reloadData()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: SongCell.id, bundle: nil)
        resultTableView.register(nib, forCellReuseIdentifier: SongCell.id)
    }
    
    private func setSearchController() {
        searchController.searchBar.placeholder = "Type songs, artists, albums..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

}

extension SearchController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = resultTableView.dequeueReusableCell(withIdentifier: SongCell.id, for: indexPath)
        
        guard let resultCell = cell as? SongCell,
              let result = result[indexPath.row] as? DeezerTrack
        else { return cell }
        
        resultCell.set(result)
        resultCell.delegate = self
        return resultCell
    }
}

extension SearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        typeSegmentedControl.isHidden = searchText.isEmpty
        DeezerProvider().findTracks(queryParameter: searchText) { tracks in
            self.result = tracks
            self.resultTableView.reloadData()
        } failure: { error in
            let alertView = SPAlertView(title: "Error", message: error, preset: .error)
            alertView.present(haptic: .error) {
                self.searchController.searchBar.text = ""
            }
        }

    }
}

extension SearchController: MenuActionsDelegate {
    func reloadData() {
        resultTableView.reloadData()
    }
    
    func presentActivityController(_ vc: UIActivityViewController) {
        self.present(vc, animated: true)
    }
}
