//
//  LibraryCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 4.02.23.
//

import UIKit

class LibraryCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    static let id = String(describing: LibraryCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(_ type: LibraryEnum) {
        iconView.image = type.icon
        nameLabel.text = type.name
    }
    
}
