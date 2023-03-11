//
//  VideoPlayer.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 9.03.23.
//

import Foundation
import AVFoundation

final class VideoPlayer {
    private(set) static var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    static weak var delegate: VideoPlayerDelegate?
    
    private static var timeObserver: Any?
    
    static func setVideo(_ link: String) {
        guard let url = URL(string: link),
              let delegate
        else { return }
        
        player = AVPlayer(url: url)
        delegate.setVideo(AVPlayerLayer(player: player))
        observeCurrentTime()
        delegate.setCoverView()
    }
    
    private static func observeCurrentTime() {
        let time = CMTime(value: 1, timescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { time in
            guard let currentItem = player.currentItem else { return }
            
            if round(currentItem.duration.seconds) == round(player.currentTime().seconds) {
                player.seek(to: .zero)
                player.play()
            }
        })
    }
    
    static func cleanVideoPlayer() {
        player = AVPlayer()
    }
}
