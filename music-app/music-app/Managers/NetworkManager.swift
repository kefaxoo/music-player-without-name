//
//  NetworkManager.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 3.03.23.
//

import UIKit
import DeviceKit

final class NetworkManager {
    static func isInternetAvailable() -> Bool {
        return UIDevice.current.internetConnection.connection == .open
    }
}
