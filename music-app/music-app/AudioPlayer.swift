//
//  AudioPlayer.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 15.03.23.
//

import Foundation
import AVKit
import MediaPlayer
import UIKit
import SDWebImage
import JDStatusBarNotification

final class AudioPlayer { }

// MARK: -
// MARK: Audio Player and contents
extension AudioPlayer {
    private(set) static var currentTrack: LibraryTrack?
    private static var currentPlaylist = [LibraryTrack]()
    private(set) static var currentIndex = 0
    private(set) static var currentCover: UIImage?
    
    private(set) static var player: AVPlayer = {
        let player = AVPlayer()
        player.volume = 1
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
}

// MARK: -
// MARK: Set functions
extension AudioPlayer {
    static func set(track: LibraryTrack, playlist: [LibraryTrack], indexInPlaylist: Int) {
        showLoadingInfo()
        currentCover = nil
        currentTrack = track
        currentPlaylist = playlist
        currentIndex = indexInPlaylist
        getImage()
        let link = getLink()
        guard let url = URL(string: link) else { return }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        observeCurrentItem()
    }
    
    private static func set() {
        showLoadingInfo()
        currentCover = nil
        currentTrack = currentPlaylist[currentIndex]
        getImage()
        let link = getLink()
        guard let url = URL(string: link) else { return }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        observeCurrentItem()
    }
    
    private static func getLink() -> String {
        guard let currentTrack else { return "" }
        
        var link = ""
        if currentTrack.cacheLink.isEmpty {
            link = currentTrack.onlineLink
        } else {
            guard let localLink = LibraryManager.getAbsolutePath(filename: currentTrack.cacheLink, path: .documentDirectory) else { return "" }
            
            link = localLink.absoluteString
        }
        
        return link
    }
    
    static func loadAsync(url: URL) async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let gResponse = response as? HTTPURLResponse,
                  gResponse.statusCode >= 200, gResponse.statusCode < 300,
                  let image = UIImage(data: data) else { return nil }
            
            return image
        } catch {
            throw error
        }
    }
    
    private static func getImage() {
        guard let currentTrack else { return }
        
        if currentTrack.coverLink.isEmpty {
            DeezerProvider.getTrack(currentTrack.id) { track in
                guard let coverLink = track.album?.coverBig,
                      let url = URL(string: coverLink)
                else { return }
                
                Task { @MainActor in
                    currentCover = try await loadAsync(url: url)
                }
            } failure: { error in
                print(error)
            }
        } else {
            currentCover = ImageManager.loadLocalImage(currentTrack.coverLink)
        }
    }
}

// MARK: -
// MARK: Setup remote
extension AudioPlayer {
    private static var info = [String : Any]()
    private static let commandCenter = MPRemoteCommandCenter.shared()
    
    private static func setupNowPlaying() {
        guard let currentTrack,
              let currentCover,
              let currentItem = player.currentItem
        else { return }
        
        setupRemoteControls()
        info[MPMediaItemPropertyTitle] = currentTrack.title
        info[MPMediaItemPropertyArtist] = currentTrack.artistName
        info[MPMediaItemPropertyAlbumTitle] = currentTrack.albumTitle
        info[MPMediaItemPropertyIsExplicit] = currentTrack.isExplicit
        info[MPMediaItemPropertyPlaybackDuration] = currentItem.duration.seconds
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
        info[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: currentCover.size, requestHandler: { size -> UIImage in
            return currentCover
        })
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private static func setupRemoteControls() {
        commandCenter.playCommand.addTarget { _ in
            if player.rate == 0 {
                var delegate: AudioPlayerDelegate?
                if nowPlayingViewDelegate != nil {
                    delegate = nowPlayingViewDelegate
                }
                
                guard let delegate else { return .commandFailed }
                
                player.play()
                delegate.playDidTap()
                return .success
            }
            
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { _ in
            if player.rate == 1 {
                var delegate: AudioPlayerDelegate?
                if nowPlayingViewDelegate != nil {
                    delegate = nowPlayingViewDelegate
                }
                
                guard let delegate else { return .commandFailed }
                
                player.pause()
                delegate.pauseDidTap()
                return .success
            }
            
            return .commandFailed
        }
        
        commandCenter.previousTrackCommand.addTarget { _ in
            //            if player.currentTime().seconds <= 5 {
            //                if counterTappingOnPreviousTrack == 0 {
            //                    playFromBegin()
            //                } else {
            //                    playPreviousTrack()
            //                    counterTappingOnPreviousTrack = 0
            //                }
            //            } else {
            //                playPreviousTrack()
            //                counterTappingOnPreviousTrack = 0
            //            }
            
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
    
    static func getDurationInFloat() -> Float {
        guard let currentItem = player.currentItem else { return 0 }
        
        return Float(currentItem.currentTime().seconds / currentItem.duration.seconds)
    }
    
    static func playDidTap() {
        player.pause()
    }
    
    static func pauseDidTap() {
        player.play()
    }
}

// MARK: -
// MARK: Queue
extension AudioPlayer {
    static func playNextTrack() {
        if currentIndex + 1 == currentPlaylist.count {
            currentIndex = 0
        } else {
            currentIndex += 1
        }
        
        set()
    }
}

// MARK: -
// MARK: Observers
extension AudioPlayer {
    private static var observer: Any?
    
    static weak var nowPlayingViewDelegate: AudioPlayerDelegate?
    
    private static var isNotificationPresenterPresented = false
    
    private static func observeCurrentItem() {
        let time = CMTime(value: 1, timescale: 600)
        observer = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { _ in
            var delegate: AudioPlayerDelegate?
            if self.nowPlayingViewDelegate != nil {
                delegate = self.nowPlayingViewDelegate
            }
            
            guard let delegate,
                  let currentItem = player.currentItem
            else { return }
            
            if currentItem.status == .readyToPlay {
                if isNotificationPresenterPresented {
                    NotificationPresenter.shared().dismiss(animated: true)
                    isNotificationPresenterPresented = false
                }
                
                delegate.setupView()
                setupNowPlaying()
                if player.rate == 0 {
                    delegate.playDidTap()
                } else {
                    delegate.pauseDidTap()
                }
                
                if round(currentItem.duration.seconds) == round(player.currentTime().seconds) {
                    playNextTrack()
                }
            }
        })
    }
    
    private static func showLoadingInfo() {
        NotificationPresenter.shared().present(text: "Loading track")
        NotificationPresenter.shared().displayActivityIndicator(true)
        isNotificationPresenterPresented = true
    }
}
