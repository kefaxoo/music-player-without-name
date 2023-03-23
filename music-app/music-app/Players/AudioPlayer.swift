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
import SPAlert

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
        isVideoLoaded = false
        player.replaceCurrentItem(with: nil)
        VideoPlayer.player.pause()
        VideoPlayer.cleanVideoPlayer()
        nowPlayingControllerDelegate?.clearVideo()
        counterTappingOnPreviousTrack = 0
        if LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
            setPlayer()
        } else {
            DeezerProvider.getTrackResponseCode(track.id) { responseCode in
                if responseCode == 200 {
                    setPlayer()
                } else {
                    if isNotificationPresenterPresented {
                        NotificationPresenter.shared().dismiss(animated: true)
                    }
                    
                    let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, preset: .error)
                    alert.present(haptic: .error)
                    playNextTrack()
                }
            }
        }
    }
    
    private static func setPlayer() {
        let link = getLink()
        guard let url = URL(string: link) else { return }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        observeCurrentItem()
    }
    
    private static func set() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        showLoadingInfo()
        currentCover = nil
        currentTrack = currentPlaylist[currentIndex]
        getImage()
        isVideoLoaded = false
        VideoPlayer.player.pause()
        VideoPlayer.cleanVideoPlayer()
        nowPlayingControllerDelegate?.clearVideo()
        counterTappingOnPreviousTrack = 0
        if LibraryManager.isTrackDownloaded(artist: currentPlaylist[currentIndex].artistName, title: currentPlaylist[currentIndex].title, album: currentPlaylist[currentIndex].albumTitle) {
            setPlayer()
        } else {
            DeezerProvider.getTrackResponseCode(currentPlaylist[currentIndex].id) { responseCode in
                if responseCode == 200 {
                    setPlayer()
                } else {
                    if isNotificationPresenterPresented {
                        NotificationPresenter.shared().dismiss(animated: true)
                    }
                    
                    let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, preset: .error)
                    alert.present(haptic: .error)
                    playNextTrack()
                }
            }
        }
    }
    
    private static func getLink() -> String {
        guard let currentTrack else { return "" }
        
        var link = ""
        if !LibraryManager.isTrackDownloaded(artist: currentTrack.artistName, title: currentTrack.title, album: currentTrack.albumTitle) {
            link = currentTrack.onlineLink
        } else {
            guard let localLink = LibraryManager.getAbsolutePath(filename: LibraryManager.getCacheLink(currentTrack), path: .documentDirectory) else { return "" }
            
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
                    nowPlayingControllerDelegate?.setCover()
                }
            } failure: { error in
                print(error)
            }
        } else {
            currentCover = ImageManager.loadLocalImage(currentTrack.coverLink)
            nowPlayingControllerDelegate?.setCover()
        }
    }
}

// MARK: -
// MARK: Setup remote
extension AudioPlayer {
    private static var info = [String : Any]()
    private static let commandCenter = MPRemoteCommandCenter.shared()
    static var editTimeOnController = true
    static var editVolumeOnController = true
    private static var counterTappingOnPreviousTrack = 0
    
    static func isShowNowPlayingOnLabel() -> Bool {
        let port = AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType
        
        return !(port == .headphones || port == .builtInSpeaker)
    }
    
    static func getNameOfOutputDevice() -> String? {
        return AVAudioSession.sharedInstance().currentRoute.outputs.first?.portName
    }
    
    static func playFromBegin() {
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
    }
    
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
    static func playPreviousTrack() {
        if player.currentTime().seconds <= 5, counterTappingOnPreviousTrack == 0 {
            playFromBegin()
            counterTappingOnPreviousTrack += 1
            return
        }
        
        if currentIndex - 1 == 0 {
            currentIndex = currentPlaylist.count - 1
        } else {
            currentIndex -= 1
        }
        
        set()
    }
    
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
    
    static weak var nowPlayingControllerDelegate: AudioPlayerDelegate?
    static weak var nowPlayingViewDelegate: AudioPlayerDelegate?
    
    private static var isNotificationPresenterPresented = false
    
    private static func observeCurrentItem() {
        let time = CMTime(value: 1, timescale: 600)
        observer = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { _ in
            var delegate: AudioPlayerDelegate?
            if self.nowPlayingViewDelegate != nil {
                delegate = self.nowPlayingViewDelegate
            }
            
            if self.nowPlayingControllerDelegate != nil {
                delegate = self.nowPlayingControllerDelegate
            }
            
            guard let delegate,
                  let currentItem = player.currentItem
            else { return }
            
            if currentItem.status == .readyToPlay {
                if !isVideoLoaded {
                    loadVideoShot()
                    isVideoLoaded = true
                }
                
                if isNotificationPresenterPresented {
                    NotificationPresenter.shared().dismiss(animated: true)
                    isNotificationPresenterPresented = false
                }
                
                delegate.setupView()
                delegate.setupController()
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

// MARK: -
// MARK: Video Show Settings
extension AudioPlayer {
    private static var isVideoLoaded = false
    static var isVideoOnScreen = false
    
    static func loadVideoShot() {
        guard let currentTrack else { return }
        
        SongLinkProvider().getLinks(currentTrack.onlineLink) { links in
            if let spotifyID = links.spotifyID {
                SpotifyProvider().getCanvasLink(spotifyID) { canvasLink in
                    if !canvasLink.isEmpty {
                        VideoPlayer.setVideo(canvasLink)
                    } else {
                        if let yandexMusicID = links.yandexMusicID {
                            YandexMusicProvider().getCanvasLink(yandexMusicID) { canvasLink in
                                VideoPlayer.setVideo(canvasLink)
                            }
                        }
                    }
                }
            } else if let yandexMusicID = links.yandexMusicID {
                YandexMusicProvider().getCanvasLink(yandexMusicID) { canvasLink in
                    VideoPlayer.setVideo(canvasLink)
                }
            }
        }
    }
}
