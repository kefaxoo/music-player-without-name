//
//  ColorSettingsCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.03.23.
//

import UIKit

class ColorSettingsCell: UITableViewCell {

    @IBOutlet weak var colorSetButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    static let id = String(describing: ColorSettingsCell.self)

    weak var delegate: MenuActionsDelegate?
    
    private var closure: SetColorClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ closure: SetColorClosure?) {
        titleLabel.text = Localization.Settings.Color.title.rawValue.localized
        let color = SettingsManager.getColor
        colorSetButton.setTitle(color.title, for: .normal)
        colorSetButton.tintColor = color.color
        self.closure = closure
    }
    
    @IBAction func colorSetButtonDidTap(_ sender: Any) {
        let colors = SettingsManager.ColorType.allCases
        var actions = [UIAction]()
        colors.forEach { color in
            let action = UIAction(title: color.title, state: SettingsManager.isColorSelected(color)) { _ in
                guard let closure = self.closure,
                      let closure,
                      let delegate = self.delegate
                else { return }
                
                SettingsManager.setColor(color)
                closure(color)
                delegate.reloadData()
            }
            
            actions.append(action)
        }
        
        colorSetButton.showsMenuAsPrimaryAction = true
        colorSetButton.menu = UIMenu(options: .displayInline, children: actions)
    }
}
