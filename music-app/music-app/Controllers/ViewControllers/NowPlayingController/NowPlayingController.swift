//
//  NowPlayingController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 24.02.23.
//

import UIKit
import TactileSlider
import SDWebImage
import SPAlert
import MediaPlayer
import AVKit
import SwiftUI

class NowPlayingController: UIViewController {
    
    @IBOutlet weak var hideControllerButton: UIButton!
    @IBOutlet weak var nowPlayingOnLabel: UILabel!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explicitView: UIImageView!
    @IBOutlet weak var menuTrackButton: UIButton!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var previousTrackButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextTrackButton: UIButton!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var noVolumeImageView: UIImageView!
    @IBOutlet weak var fullVolumeImageView: UIImageView!
    @IBOutlet weak var airplayButton: UIButton!
    @IBOutlet weak var videoShotView: UIView!
    
    lazy var volumeSlider: TactileSlider = {
        let slider = TactileSlider(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 92, height: 10))
        slider.enableTapping = true
        slider.tintColor = SettingsManager.getColor.color
        slider.addTarget(self, action: #selector(volumeDidChange), for: [.touchUpInside, .touchUpOutside])
        slider.addTarget(self, action: #selector(volumeWillChange), for: .touchDown)
        return slider
    }()
    
    lazy var durationSlider: TactileSlider = {
        let slider = TactileSlider(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 10))
        slider.enableTapping = true
        slider.tintColor = SettingsManager.getColor.color
        slider.steppingMode = .stepValue(1)
        slider.addTarget(self, action: #selector(durationDidChange), for: [.touchUpInside, .touchUpOutside])
        slider.addTarget(self, action: #selector(durationWillChange), for: .touchDown)
        return slider
    }()
    
    weak var delegate: ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(viewSwipeDown))
        swipeGesture.direction = .down
        self.view.addGestureRecognizer(swipeGesture)
        set()
    }
    
    override func viewDidLayoutSubviews() {
        if VideoPlayer.player.currentItem != nil, AudioPlayer.player.rate != 0, !AudioPlayer.isVideoOnScreen {
            AudioPlayer.isVideoOnScreen = true
            VideoPlayer.setVideo()
        }
    }
    
    @objc private func viewSwipeDown() {
        self.dismiss(animated: true)
    }
    
    @objc private func volumeWillChange() {
        AudioPlayer.editVolumeOnController = false
    }
    
    @objc private func volumeDidChange() {
        MPVolumeView.setVolume(volumeSlider.value)
        AudioPlayer.editVolumeOnController = true
    }
    
    @objc private func durationWillChange() {
        AudioPlayer.editTimeOnController = false
    }
    
    @objc private func durationDidChange() {
        let time = CMTime(seconds: Double(durationSlider.value), preferredTimescale: 600)
        AudioPlayer.player.seek(to: time)
        AudioPlayer.editTimeOnController = true
    }
    
    func set() {
        guard let track = AudioPlayer.currentTrack else { return }
        
        AudioPlayer.nowPlayingControllerDelegate = self
        VideoPlayer.delegate = self
        
        if let cover = AudioPlayer.currentCover {
            coverView.image = cover
        }
        
        coverView.layer.cornerRadius = 20
        titleLabel.text = track.title
        explicitView.isHidden = !track.isExplicit
        explicitView.tintColor = SettingsManager.getColor.color
        artistLabel.text = track.artistName
        artistLabel.textColor = artistLabel.textColor.withAlphaComponent(0.8)
        durationSlider.maximum = Float(track.duration)
        durationView.addSubview(durationSlider)
        currentTimeLabel.textColor = currentTimeLabel.textColor.withAlphaComponent(0.8)
        durationLabel.textColor = durationLabel.textColor.withAlphaComponent(0.8)
        previousTrackButton.imageView?.contentMode = .scaleAspectFit
        previousTrackButton.tintColor = SettingsManager.getColor.color
        playPauseButton.imageView?.contentMode = .scaleAspectFit
        playPauseButton.tintColor = SettingsManager.getColor.color
        nextTrackButton.imageView?.contentMode = .scaleAspectFit
        nextTrackButton.tintColor = SettingsManager.getColor.color
        noVolumeImageView.tintColor = SettingsManager.getColor.color
        volumeView.addSubview(volumeSlider)
        volumeSlider.setValue(AVAudioSession.sharedInstance().outputVolume, animated: true)
        fullVolumeImageView.tintColor = SettingsManager.getColor.color
        airplayButton.tintColor = SettingsManager.getColor.color
        nowPlayingOnLabel.tintColor = SettingsManager.getColor.color
        makeCoverSmaller()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AudioPlayer.nowPlayingControllerDelegate = nil
        VideoPlayer.player.pause()
        VideoPlayer.player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        AudioPlayer.isVideoOnScreen = false
        videoShotView.subviews.forEach { view in
            view.removeFromSuperview()
        }
    }
    
    @IBAction func menuTrackButtonDidTap(_ sender: Any) {
        let actionManager = ActionsManager()
        actionManager.delegate = self
        guard let track = AudioPlayer.currentTrack,
              let showAlbumAction = actionManager.showAlbumAction(id: track.albumID, title: track.albumTitle),
              let showArtistAction = actionManager.showArtistAction(id: track.artistID, name: track.artistName)
        else { return }
        
        menuTrackButton.showsMenuAsPrimaryAction = true
        menuTrackButton.menu = UIMenu(options: .displayInline, children: [showAlbumAction, showArtistAction])
    }
    
    @IBAction func showAirplayMenuAction(_ sender: Any) {
        let rect = CGRect(x: -100, y: 0, width: 0, height: 0)
        let airplayVolume = MPVolumeView(frame: rect)
        airplayVolume.showsVolumeSlider = false
        self.view.addSubview(airplayVolume)
        for view: UIView in airplayVolume.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
        
        airplayVolume.removeFromSuperview()
    }
    
    @IBAction func menuButtonDidTap(_ sender: Any) {
        guard let track = AudioPlayer.currentTrack else { return }
        
        var libraryActions = [UIAction]()
        
        let actionsManager = ActionsManager()
        actionsManager.delegate = self
        
        guard let addToPlaylistAction = actionsManager.addToPlaylistAction(track) else { return }
        
        libraryActions.append(addToPlaylistAction)
        
        if LibraryManager.isTrackInLibrary(track.id) {
            guard let removeFromLibraryAction = actionsManager.removeFromLibrary(track.id) else { return }
            
            libraryActions.append(removeFromLibraryAction)
            
            if !LibraryManager.isTrackDownloaded(artist: track.artistName, title: track.title, album: track.albumTitle) {
               guard let removeTrackFromCacheAction = actionsManager.removeFromLibrary(track.id) else { return }
                
                libraryActions.append(removeTrackFromCacheAction)
            } else {
                guard let downloadToCacheAction = actionsManager.downloadTrackAction(track: track)
                else { return }
                
                libraryActions.append(downloadToCacheAction)
            }
        } else {
            guard let addToLibraryAction = actionsManager.likeTrackAction(track.id) else { return }
            
            libraryActions.append(addToLibraryAction)
        }
        
        let libraryActionsMenu = UIMenu(options: .displayInline, children: libraryActions)
        
        guard let shareSongAction = actionsManager.shareSongAction(track.id),
              let shareLinkAction = actionsManager.shareLinkAction(id: track.id, type: .track)
        else { return }
        
        let shareActionsMenu = UIMenu(options: .displayInline, children: [shareSongAction, shareLinkAction])
        
        guard let showAlbumAction = actionsManager.showAlbumAction(id: track.albumID, title: track.albumTitle),
              let showArtistAction = actionsManager.showArtistAction(track.artistID)
        else { return }
        
        let showActionsMenu = UIMenu(options: .displayInline, children: [showAlbumAction, showArtistAction])
        
        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(children: [showActionsMenu, shareActionsMenu, libraryActionsMenu])
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func playPauseDidTap(_ sender: Any) {
        if AudioPlayer.player.rate == 0 {
            AudioPlayer.pauseDidTap()
        } else {
            AudioPlayer.playDidTap()
        }
    }
    
    @IBAction func nextTrackDidTap(_ sender: Any) {
        AudioPlayer.playNextTrack()
    }
    
    @IBAction func previousTrackDidTap(_ sender: Any) {
        AudioPlayer.playPreviousTrack()
    }
}

extension NowPlayingController: AudioPlayerDelegate {
    func playDidTap() {
        makeCoverSmaller()
        pauseVideoShot()
    }
    
    func pauseDidTap() {
        makeCoverBigger()
        playVideoShot()
    }
    
    func previousTrackDidTap() {
        pauseVideoShot()
        set()
    }
    
    func nextTrackDidTap() {
        pauseVideoShot()
        set()
    }
    
    func setupController() {
        guard let currentTime = AudioPlayer.player.currentItem?.currentTime().seconds,
              let duration = AudioPlayer.player.currentItem?.duration.seconds,
              let track = AudioPlayer.currentTrack
        else { return }
        
        titleLabel.text = track.title
        artistLabel.text = track.artistName
        
        if AudioPlayer.editTimeOnController {
            durationSlider.setValue(Float(currentTime), animated: false)
            currentTimeLabel.text = currentTime.time
            durationLabel.text = "-\((duration - currentTime).time)"
        }
        
        if AudioPlayer.player.rate == 0 {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }

        nowPlayingOnLabel.isHidden = !AudioPlayer.isShowNowPlayingOnLabel()
        
        if AudioPlayer.isShowNowPlayingOnLabel() {
            guard let nameOfDevice = AudioPlayer.getNameOfOutputDevice() else { return }
            
            nowPlayingOnLabel.text = nameOfDevice
        }
        
        if volumeSlider.value != AVAudioSession.sharedInstance().outputVolume, AudioPlayer.editVolumeOnController {
            volumeSlider.setValue(AVAudioSession.sharedInstance().outputVolume, animated: true)
        }
    }
    
    func trackDidLoad() {
        makeCoverBigger()
    }
    
    func setCover() {
        coverView.image = AudioPlayer.currentCover
    }
    
    func clearVideo() {
        AudioPlayer.isVideoOnScreen = false
        videoShotView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        
        uiPause()
    }
}

// MARK: -
// MARK: Menu Actions Delegate Extension

extension NowPlayingController: MenuActionsDelegate {
    func dismiss() {
        self.dismiss(animated: true)
    }
    
    func dismiss(_ alert: SPAlertView) {
        alert.dismiss()
    }
    
    func pushViewController(_ vc: UIViewController) {
        delegate?.pushVC(vc)
    }
    
    func present(_ vc: UIActivityViewController) {
        present(vc, animated: true)
    }
    
    func present(alert: SPAlertView, haptic: SPAlertHaptic) {
        alert.present(haptic: haptic)
    }
    
    func present(_ vc: UIViewController) {
        present(vc, animated: true)
    }
}

// MARK: -
// MARK: Video Player Delegate

extension NowPlayingController: VideoPlayerDelegate {
    func setVideo(_ layer: AVPlayerLayer) {
        layer.frame = videoShotView.bounds
        videoShotView.layer.addSublayer(layer)
        layer.videoGravity = .resizeAspectFill
        VideoPlayer.player.play()
    }
    
    func setCoverView() {
        if VideoPlayer.player.rate == 0 {
            uiPause()
        } else {
            uiPlay()
        }
    }
}

// MARK: -
// MARK: Animations

extension NowPlayingController {
    private func playVideoShot() {
        if VideoPlayer.player.currentItem != nil {
            VideoPlayer.player.play()
            uiPlay()
        }
    }
    
    private func uiPlay() {
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.coverView.alpha = 0
            self.videoShotView.alpha = 1

            self.hideControllerButton.tintColor = UIColor.white
            self.titleLabel.textColor = UIColor.white
            self.artistLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            self.menuButton.tintColor = UIColor.white
            self.durationLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            self.currentTimeLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            self.nowPlayingOnLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        }
    }
    
    private func uiPause() {
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.coverView.alpha = 1
            self.videoShotView.alpha = 0
            
            self.hideControllerButton.tintColor = UIColor.label
            self.titleLabel.textColor = UIColor.label
            self.artistLabel.textColor = UIColor.label.withAlphaComponent(0.8)
            self.menuButton.tintColor = UIColor.label
            self.durationLabel.textColor = UIColor.label.withAlphaComponent(0.8)
            self.currentTimeLabel.textColor = UIColor.label.withAlphaComponent(0.8)
            self.nowPlayingOnLabel.textColor = UIColor.label.withAlphaComponent(0.8)
            
        }
    }
    
    private func pauseVideoShot() {
        if VideoPlayer.player.currentItem != nil {
            VideoPlayer.player.pause()
            uiPause()
        }
    }
    
    private func makeCoverBigger() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.coverView.transform = .identity
        }
    }
    
    private func makeCoverSmaller() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            let scale = 0.8
            self.coverView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}
