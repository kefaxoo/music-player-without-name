//
//  ViewControllerDelegate.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import UIKit

protocol ViewControllerDelegate: AnyObject {
    func pushVC(_ vc: UIViewController)
}
