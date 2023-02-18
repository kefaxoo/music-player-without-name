//
//  MenuActionsDelegate.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import UIKit

protocol MenuActionsDelegate: AnyObject {
    func reloadData()
    func presentActivityController(_ vc: UIActivityViewController)
    func pushViewController(_ vc: UIViewController)
}

extension MenuActionsDelegate {
    func reloadData() {}
    func presentActivityController(_ vc: UIActivityViewController) {}
    func pushViewController(_ vc: UIViewController) {}
}
