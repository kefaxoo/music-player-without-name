//
//  MenuActionsDelegate.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import UIKit
import SPAlert

protocol MenuActionsDelegate: AnyObject {
    func reloadData()
    func present(_ vc: UIActivityViewController)
    func pushViewController(_ vc: UIViewController)
    func dismissViewController()
    func present(alert: SPAlertView, haptic: SPAlertHaptic)
}

extension MenuActionsDelegate {
    func reloadData() {}
    func present(_ vc: UIActivityViewController) {}
    func pushViewController(_ vc: UIViewController) {}
    func dismissViewController() {}
    func present(alert: SPAlertView, haptic: SPAlertHaptic = .none) {}
}
