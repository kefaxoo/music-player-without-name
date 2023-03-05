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
    
    lazy var volumeSlider: TactileSlider = {
        let slider = TactileSlider(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 92, height: 10))
        slider.enableTapping = true
        slider.tintColor = .systemPurple
        slider.addTarget(self, action: #selector(volumeDidChange), for: [.touchUpInside, .touchUpOutside])
        slider.addTarget(self, action: #selector(volumeWillChange), for: .touchDown)
        return slider
    }()
    
    lazy var durationSlider: TactileSlider = {
        let slider = TactileSlider(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 10))
        slider.enableTapping = true
        slider.tintColor = .systemPurple
        slider.steppingMode = .stepValue(1)
        slider.addTarget(self, action: #selector(durationDidChange), for: [.touchUpInside, .touchUpOutside])
        slider.addTarget(self, action: #selector(durationWillChange), for: .touchDown)
        return slider
    }()
    
    private var track: DeezerTrack?
    
    weak var delegate: ViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(viewSwipeDown))
        swipeGesture.direction = .down
        self.view.addGestureRecognizer(swipeGesture)
        setInterface()
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
    
    private func setInterface() {
        guard let track,
              let coverLink = track.album?.coverBig
        else { return }
        
        coverView.sd_setImage(with: URL(string: coverLink))
        coverView.layer.cornerRadius = 20
        titleLabel.text = track.title
        explicitView.isHidden = !track.isExplicit
        artistLabel.text = track.artist?.name
        artistLabel.textColor = artistLabel.textColor.withAlphaComponent(0.8)
        durationSlider.maximum = Float(track.duration)
        durationView.addSubview(durationSlider)
        currentTimeLabel.textColor = currentTimeLabel.textColor.withAlphaComponent(0.8)
        durationLabel.textColor = durationLabel.textColor.withAlphaComponent(0.8)
        previousTrackButton.imageView?.contentMode = .scaleAspectFit
        playPauseButton.imageView?.contentMode = .scaleAspectFit
        nextTrackButton.imageView?.contentMode = .scaleAspectFit
        volumeView.addSubview(volumeSlider)
        volumeSlider.setValue(AVAudioSession.sharedInstance().outputVolume, animated: true)
        makeSmallCover()
    }
    
    func set() {
        guard let track = AudioPlayer.currentTrack else { return }
        self.track = track
        AudioPlayer.delegate = self
    }
    
    func set(track: DeezerTrack?, playlist: [DeezerTrack] = [DeezerTrack](), indexInPlaylist: Int = 0) {
        guard let track else { return }
        
        self.track = track
        var currentPlaylist = playlist
        if currentPlaylist.isEmpty {
            currentPlaylist = [track]
        }
        
        AudioPlayer.set(track: track, playlist: currentPlaylist, indexInPlaylist: indexInPlaylist)
        currentPlaylist = [DeezerTrack]()
        let tracks = RealmManager<LibraryTrack>().read()
        tracks.forEach { track in
            DeezerProvider.getTrack(track.id) { track in
                currentPlaylist.append(track)
                if currentPlaylist.count == tracks.count {
                    currentPlaylist = currentPlaylist.sorted(by: { trackI, trackJ in
                        return trackI.title < trackJ.title
                    })
                    
                    guard let index = currentPlaylist.firstIndex(where: { $0.id == track.id }) else { return }
                    
                    AudioPlayer.setPlaylistAndIndex(playlist: currentPlaylist, indexInPlaylist: index)
                }
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                alert.present(haptic: .error)
            }
            
        }
        AudioPlayer.delegate = self
    }
    
    @IBAction func menuTrackButtonDidTap(_ sender: Any) {
        let actionManager = ActionsManager()
        actionManager.delegate = self
        guard let track,
              let artist = track.artist,
              let album = track.album,
              let showArtistAction = actionManager.showArtistAction(artist),
              let showAlbumAction = actionManager.showAlbumAction(album)
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
        guard let track = self.track,
              let delegate
        else { return }
        
        var libraryActions = [UIAction]()
        
        if LibraryManager.isTrackInLibrary(track.id) {
            let removeFromLibraryAction = UIAction(title: MenuActionsEnum.removeFromLibrary.title, image: MenuActionsEnum.removeFromLibrary.image, attributes: .destructive) { _ in
                guard let removingTrack = RealmManager<LibraryTrack>().read().first(where: { $0.id == track.id }) else { return }
                
                RealmManager<LibraryTrack>().delete(object: removingTrack)
                let alertView = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
                alertView.present(haptic: .success)
            }
            
            libraryActions.append(removeFromLibraryAction)
            
            if LibraryManager.isTrackIsDownloaded(track),
               let trackInLibrary = LibraryManager.trackInLibrary(track.id) {
                let removeTrackFromCacheAction = UIAction(title: MenuActionsEnum.deleteDownload.title, image: MenuActionsEnum.deleteDownload.image, attributes: .destructive) { _ in
                    var alert = SPAlertView(title: "", preset: .spinner)
                    alert.dismissByTap = false
                    alert.present()
                    alert.dismiss()
                    if let path = LibraryManager.getAbsolutePath(filename: trackInLibrary.cacheLink, path: .documentDirectory) {
                        try? FileManager.default.removeItem(at: path)
                        alert = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
                        alert.present(haptic: .success)
                    } else {
                        alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                        alert.present(haptic: .error)
                    }
                }
                
                libraryActions.append(removeTrackFromCacheAction)
            } else {
                let downloadToCacheAction = UIAction(title: MenuActionsEnum.download.title.localized, image: MenuActionsEnum.download.image) { _ in
                    var alert = SPAlertView(title: "", preset: .spinner)
                    alert.dismissByTap = false
                    guard let artist = track.artist?.name,
                          let album = track.album?.title
                    else { return }
                    
                    alert.present()
                    
                    let filename = "Music/\(artist.toUnixFilename) - \(track.title.toUnixFilename) - \(album.toUnixFilename).mp3"
                    if let trackDirectoryURL = LibraryManager.getAbsolutePath(filename: filename, path: .documentDirectory),
                       let trackURL = URL(string: track.downloadLink) {
                        URLSession.shared.downloadTask(with: trackURL) { tempFileURL, response, error in
                            if let trackTempFileURL = tempFileURL {
                                do {
                                    let trackData = try Data(contentsOf: trackTempFileURL)
                                    try trackData.write(to: trackDirectoryURL)
                                    DispatchQueue.main.async {
                                        alert.dismiss()
                                        alert = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
                                        alert.present(haptic: .success)
                                    }
                                } catch {
                                    alert.dismiss()
                                    alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                                    alert.present(haptic: .error)
                                }
                            }
                        }.resume()
                    }
                }
                
                libraryActions.append(downloadToCacheAction)
            }
        } else {
            let addToLibraryAction = UIAction(title: MenuActionsEnum.addToLibrary.title, image: MenuActionsEnum.addToLibrary.image) { _ in
                let alertView = SPAlertView(title: "", preset: .spinner)
                alertView.dismissByTap = false
                alertView.present()
                DeezerProvider.getTrack(track.id, success: { track in
                    let newTrack = LibraryTrack(id: track.id, title: track.title, duration: track.duration, trackPosition: track.trackPosition!, diskNumber: track.diskNumber!, isExplicit: track.isExplicit, artistID: track.artist!.id, albumID: track.album!.id, onlineLink: "", cacheLink: "")
                    
                    RealmManager<LibraryTrack>().write(object: newTrack)
                    alertView.dismiss()
                    let alertView = SPAlertView(title: Localization.Alert.Title.success.rawValue.localized, preset: .done)
                    alertView.present(haptic: .success)
                }, failure: { error in
                    alertView.dismiss()
                    let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: error, preset: .error)
                    alertView.present(haptic: .error)
                })
            }
            
            libraryActions.append(addToLibraryAction)
        }
        
        let libraryActionsMenu = UIMenu(options: .displayInline, children: libraryActions)
        
        let shareSongAction = UIAction(title: MenuActionsEnum.shareSong.title, image: MenuActionsEnum.shareSong.image) { _ in
            let alertView = SPAlertView(title: "", preset: .spinner)
            alertView.dismissByTap = false
            alertView.present()
            
            guard let artist = track.artist?.name,
                  let album = track.album?.title
            else { return }
            
            let tempDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let trackName = "\(artist) - \(track.title) - \(album).mp3"
            let trackDirectoryURL = tempDirectoryURL.appendingPathComponent(trackName.toUnixFilename)
            if let trackURL = URL(string: track.downloadLink) {
                URLSession.shared.downloadTask(with: trackURL) { (tempFileUrl, response, error) in
                    if let trackTempFileUrl = tempFileUrl {
                        do {
                            let trackData = try Data(contentsOf: trackTempFileUrl)
                            try trackData.write(to: trackDirectoryURL)
                            DispatchQueue.main.async {
                                let activityViewController = UIActivityViewController(activityItems: [trackDirectoryURL], applicationActivities: nil)
                                activityViewController.excludedActivityTypes = [.airDrop, .mail, .message]
                                alertView.dismiss()
                                self.present(activityViewController, animated: true)
                                activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                                    if completed {
                                        do {
                                            try FileManager.default.removeItem(at: trackDirectoryURL)
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            }
                        } catch {
                            alertView.dismiss()
                            let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                            alertView.duration = 5
                            alertView.present(haptic: .error)
                        }
                    }
                }.resume()
            }
        }
        
        let shareLinkAction = UIAction(title: MenuActionsEnum.shareLink.title, image: MenuActionsEnum.shareLink.image) { _ in
            guard let track = self.track,
                  let artist = track.artist
            else { return }
            
            SongLinkProvider().getShareLink(track.shareLink) { link in
                let text = Localization.MenuActions.ShareLink.shareMessage.rawValue.localizedWithParameters(title: track.title, artist: artist.name, link: link)
                let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                
                activityViewController.excludedActivityTypes = [.airDrop, .mail, .message]
                self.present(activityViewController, animated: true)
            } failure: { error in
                let alertView = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, preset: .error)
                alertView.duration = 5
                alertView.present(haptic: .error)
            }
        }
        
        let shareActionsMenu = UIMenu(options: .displayInline, children: [shareSongAction, shareLinkAction])
        
        let showAlbumAction = UIAction(title: MenuActionsEnum.showAlbum.title, image: MenuActionsEnum.showAlbum.image) { _ in
            guard let albumID = track.album?.id else { return }
            
            var alert = SPAlertView(title: "", preset: .spinner)
            alert.dismissByTap = false
            alert.present()
            DeezerProvider.getAlbum(albumID) { album in
                let albumVC = AlbumController()
                albumVC.set(album)
                alert.dismiss()
                self.dismiss(animated: true)
                delegate.pushVC(albumVC)
            } failure: { error in
                alert.dismiss()
                alert = SPAlertView(title: Localization.Alert.Title.error.rawValue.localized, message: error, preset: .error)
                alert.present(haptic: .error)
            }
        }
        
        guard let artist = track.artist else { return }
        
        let showArtistAction = UIAction(title: MenuActionsEnum.showArtist.title, image: MenuActionsEnum.showArtist.image) { _ in
            DeezerProvider.getArtist(artist.id) { artist in
                let artistVC = ArtistController()
                artistVC.set(artist)
                self.dismiss(animated: true)
                delegate.pushVC(artistVC)
            } failure: { error in
                let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
                alert.present(haptic: .error)
            }
        }
        
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
    
    private func makeSmallCover() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            let scale = 0.8
            self.coverView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    private func makeLargeCover() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.coverView.transform = .identity
        }
    }
    
    @IBAction func nextTrackDidTap(_ sender: Any) {
        AudioPlayer.playNextTrack()
    }
    
    @IBAction func previousTrackDidTap(_ sender: Any) {
        AudioPlayer.playFromBegin()
    }
}

extension NowPlayingController: AudioPlayerDelegate {
    func playDidTap() {
        makeSmallCover()
    }
    
    func pauseDidTap() {
        makeLargeCover()
    }
    
    func previousTrackDidTap() {
        track = AudioPlayer.currentTrack
        set()
    }
    
    func nextTrackDidTap() {
        track = AudioPlayer.currentTrack
        set()
    }
    
    func setupController() {
        guard let currentTime = AudioPlayer.player.currentItem?.currentTime().seconds,
              let duration = AudioPlayer.player.currentItem?.duration.seconds
        else { return }
        
        if AudioPlayer.editTimeOnController {
            durationSlider.setValue(Float(currentTime), animated: true)
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
            
            nowPlayingOnLabel.text = "Now playing on \(nameOfDevice)"
        }
        
        if volumeSlider.value != AVAudioSession.sharedInstance().outputVolume, AudioPlayer.editVolumeOnController {
            volumeSlider.setValue(AVAudioSession.sharedInstance().outputVolume, animated: true)
        }
    }
    
    func trackDidLoad() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut) {
            self.coverView.transform = .identity
        }
    }
}

extension NowPlayingController: MenuActionsDelegate {
    func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    func pushViewController(_ vc: UIViewController) {
        delegate?.pushVC(vc)
    }
    
    func present(alert: SPAlertView, haptic: SPAlertHaptic = .none) {
        alert.present(haptic: haptic)
    }
}
