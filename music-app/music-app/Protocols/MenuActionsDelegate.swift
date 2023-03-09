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
    func present(_ vc: UIViewController)
    func present(_ alert: UIAlertController)
    func dismiss()
    func dismiss(_ alert: SPAlertView)
    func present(alert: SPAlertView, haptic: SPAlertHaptic)
    func startDonwloadSpinner()
    func stopDownloadSpinner()
    func popVC()
}

extension MenuActionsDelegate {
    func reloadData() {}
    func present(_ vc: UIActivityViewController) {}
    func pushViewController(_ vc: UIViewController) {}
    func present(_ vc: UIViewController) {}
    func present(_ alert: UIAlertController) {}
    func dismiss() {}
    func dismiss(_ alert: SPAlertView) {}
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {}
    func startDonwloadSpinner() {}
    func stopDownloadSpinner() {}
    func popVC() {}
}
