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
    func setupView()
    func trackDidLoad()
    func setCover()
}

extension AudioPlayerDelegate {
    func playDidTap() {}
    func pauseDidTap() {}
    func previousTrackDidTap() {}
    func setupController() {}
    func setupView() {}
    func trackDidLoad() {}
    func nextTrackDidTap() {}
    func setCover() {}
}
