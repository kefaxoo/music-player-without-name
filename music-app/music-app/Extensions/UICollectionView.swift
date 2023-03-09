//
//  UICollectionView.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.03.23.
//

import UIKit

extension UICollectionView {
    func register(_ cells: AnyClass...) {
        cells.forEach { cell in
            let id = String(describing: cell.self)
            let nib = UINib(nibName: id, bundle: nil)
            self.register(nib, forCellWithReuseIdentifier: id)
        }
    }
}
