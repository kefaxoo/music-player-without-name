//
//  SettingsController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.03.23.
//

import UIKit

typealias SetColorClosure = ((SettingsManager.ColorType) -> ())?

class SettingsController: UIViewController {
    
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var nowPlayingView: NowPlayingView!
    
    static let id = String(describing: SettingsController.self)
    
    private let settingsPoints = SettingsManager.SettingType.allCases
    
    private var closure: SetColorClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.dataSource = self
        settingsTableView.register(ColorSettingsCell.self)
    }
    
    func set(_ closure: SetColorClosure) {
        self.closure = closure
    }

}

extension SettingsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsPoints.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: ColorSettingsCell.id, for: indexPath)
        
        guard let colorSettingCell = cell as? ColorSettingsCell else { return cell }
        
        colorSettingCell.delegate = self
        colorSettingCell.set(closure)
        return colorSettingCell
    }
}

extension SettingsController: MenuActionsDelegate {
    func reloadData() {
        settingsTableView.reloadData()
    }
    
    func present(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
}
