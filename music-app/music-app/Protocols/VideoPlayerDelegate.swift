//
//  VideoPlayerDelegate.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 9.03.23.
//

import Foundation
import AVFoundation

protocol VideoPlayerDelegate: AnyObject {
    func setVideo(_ layer: AVPlayerLayer)
    func setCoverView()
}
