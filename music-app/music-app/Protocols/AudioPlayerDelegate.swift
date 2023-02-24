//
//  AudioPlayerDelegate.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 24.02.23.
//

import Foundation

protocol AudioPlayerDelegate: AnyObject {
    func playDidTap()
    func pauseDidTap()
    func previousTrackDidTap()
    func nextTrackDidTap()
    func setupController()
    func trackDidLoad()
}

extension AudioPlayerDelegate {
    func previousTrackDidTap() {}
    func setupController() {}
    func trackDidLoad() {}
}
