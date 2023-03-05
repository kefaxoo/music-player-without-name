//
//  AudioPlayer.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 24.02.23.
//

import Foundation
import AVKit
import MediaPlayer

final class AudioPlayer {
    private(set) static var player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        player.volume = 1
        return player
    }()
    
    private static var timeObserver: Any?
    
    private static var counterTappingOnPreviousTrack = 0
    
    static weak var delegate: AudioPlayerDelegate?
    static weak var nowPlayingViewDelegate: AudioPlayerDelegate?
    
    static var editTimeOnController = true
    
    static var editVolumeOnController = true
    
    static func set(track: DeezerTrack, playlist: [DeezerTrack], indexInPlaylist: Int) {
        currentTrack = track
        if playlist.count == 0 {
            currentPlaylist = [track]
        } else {
            currentPlaylist = playlist
        }
        
        currentIndex = indexInPlaylist
        
        var link = ""
        if !LibraryManager.isTrackIsDownloaded(track) {
            link = track.downloadLink
        } else {
            guard let localLink = LibraryManager.getAbsolutePath(filename: "Music/\(track.artist!.name) - \(track.title) - \(track.album!.title).mp3", path: .documentDirectory) else { return }
            
            link = localLink.absoluteString
        }
        
        print(link)
        
        guard let url = URL(string: link) else { return }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        observeCurrentTime()
    }
    
    static func setPlaylistAndIndex(playlist: [DeezerTrack], indexInPlaylist: Int) {
        currentPlaylist = playlist
        currentIndex = indexInPlaylist
    }
}

// MARK: Current playlist and track variables
extension AudioPlayer {
    // track info
    private(set) static var currentTrack: DeezerTrack?
    private static var cover: UIImage?
    
    private(set) static var currentPlaylist = [DeezerTrack]()
    private(set) static var currentIndex = 0
    
    // nowPlaying variables
    private static var info = [String:Any]()
    private static let commandCenter = MPRemoteCommandCenter.shared()
}

// MARK: Control functions
extension AudioPlayer {
    static func playFromBegin() {
        if let currentTime = player.currentItem?.currentTime().seconds,
           currentTime > 10 {
            playPreviousTrack()
        }
        
        player.seek(to: CMTime(value: 0, timescale: 600))
        counterTappingOnPreviousTrack += 1
        if counterTappingOnPreviousTrack > 1 {
            playPreviousTrack()
        }
    }
    
    private static func playPreviousTrack() {
        guard let delegate else { return }
        
        if currentIndex - 1 < 0 {
            currentIndex = currentPlaylist.count - 1
        } else {
            currentIndex -= 1
        }
        
        currentTrack = currentPlaylist[currentIndex]
        counterTappingOnPreviousTrack = 0
        guard let link = currentTrack?.downloadLink,
              let url = URL(string: link)
        else { return }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        delegate.previousTrackDidTap()
    }
    
    static func playNextTrack() {
        guard let delegate else { return }
        
        if currentIndex + 1 >= currentPlaylist.count {
            currentIndex = 0
        } else {
            currentIndex += 1
        }
        
        currentTrack = currentPlaylist[currentIndex]
        guard let link = currentTrack?.downloadLink,
              let url = URL(string: link)
        else { return }
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        delegate.nextTrackDidTap()
    }
    
    static func playDidTap() {
        player.rate = 0
    }
    
    static func pauseDidTap() {
        player.rate = 1
    }
}

// MARK: Setup now playing controls and info
extension AudioPlayer {
    private static func setupRemoteControls() {
        commandCenter.playCommand.addTarget { _ in
            if player.rate == 0 {
                guard let delegate else { return .commandFailed }
                
                player.play()
                delegate.playDidTap()
                return .success
            }
            
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { _ in
            if player.rate == 1 {
                guard let delegate else { return .commandFailed }
                
                player.pause()
                delegate.pauseDidTap()
                return .success
            }
            
            return .commandFailed
        }
        
        commandCenter.previousTrackCommand.addTarget { _ in
            if player.currentTime().seconds <= 5 {
                if counterTappingOnPreviousTrack == 0 {
                    playFromBegin()
                } else {
                    playPreviousTrack()
                    counterTappingOnPreviousTrack = 0
                }
            } else {
                playPreviousTrack()
                counterTappingOnPreviousTrack = 0
            }
            
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { _ in
            playNextTrack()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { commandEvent in
            let playerRate = player.rate
            if let event = commandEvent as? MPChangePlaybackPositionCommandEvent {
                player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: 600)) { success in
                    if success {
                        player.rate = playerRate
                    }
                }
            }
            
            return .success
        }
    }
    
    private static func setupTimeInNowPlaying() {
        guard let currentItem = player.currentItem else { return }
        
        info[MPMediaItemPropertyPlaybackDuration] = currentItem.duration.seconds
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = (currentItem.currentTime()).seconds
        info[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private static func setupNowPlaying() {
        guard let currentTrack,
              let artist = currentTrack.artist?.name,
              let album = currentTrack.album
        else { return }
        
        setupRemoteControls()
        info[MPMediaItemPropertyTitle] = currentTrack.title
        info[MPMediaItemPropertyArtist] = artist
        info[MPMediaItemPropertyAlbumTitle] = album.title
        info[MPMediaItemPropertyIsExplicit] = currentTrack.isExplicit
        cover = nil
        UIImageView().sd_setImage(with: URL(string: album.coverBig)) { cover, _, _, _ in
            guard let cover else { return }
            
            self.cover = cover
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: cover.size, requestHandler: { size -> UIImage in
                return cover
            })
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private static func funnsss() {
        // portDescription.portType
        // BluetoothA2DPOutput - maybe airpods
        // Speaker
        // Airplay
        // portDescription.portName - name of outputDevice
        
        AVAudioSession.sharedInstance().currentRoute.outputs.forEach { portDescription in
            print(portDescription.portType)
            print(portDescription.portName)
        }
    }
    
    static func observeCurrentTime() {
        let time = CMTime(value: 1, timescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { time in
            var delegate: AudioPlayerDelegate?
            if self.delegate != nil {
                delegate = self.delegate
            } else if nowPlayingViewDelegate != nil {
                delegate = nowPlayingViewDelegate
            }
            
            guard let delegate,
                  let currentItem = player.currentItem
            else { return }
            
            delegate.setupController()
            delegate.trackDidLoad()
            delegate.setupView()
            setupNowPlaying()
            setupTimeInNowPlaying()
            setupRemoteControls()
            //funnsss()
            if player.rate == 0 {
                delegate.playDidTap()
            } else {
                delegate.pauseDidTap()
            }
            
            if round(currentItem.duration.seconds) == round(player.currentTime().seconds) {
                playNextTrack()
            }
        })
    }
}

extension AudioPlayer {
    static func isShowNowPlayingOnLabel() -> Bool {
        let port = AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType
        
        return !(port == .headphones || port == .builtInSpeaker)
    }
    
    static func getNameOfOutputDevice() -> String? {
        return AVAudioSession.sharedInstance().currentRoute.outputs.first?.portName
    }
}
