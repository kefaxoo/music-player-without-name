//
//  NowPlayingView.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 25.02.23.
//

import UIKit
import SDWebImage

class NowPlayingView: UIView {

    @IBOutlet var contentView: NowPlayingView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var durationProgressView: UIProgressView!
    @IBOutlet weak var nextTrackButton: UIButton!
    
    private var track: DeezerTrack?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: NowPlayingView.self), owner: self)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        AudioPlayer.nowPlayingViewDelegate = self
        set()
        setInterface()
    }
    
    private func setInterface() {
        playPauseButton.tintColor = SettingsManager.getColor.color
        nextTrackButton.tintColor = SettingsManager.getColor.color
        durationProgressView.tintColor = SettingsManager.getColor.color
    }
    
    func set() {
        track = AudioPlayer.currentTrack
        AudioPlayer.observeCurrentTime()
        guard let track,
              let coverLink = track.album?.coverSmall,
              let artist = track.artist?.name
        else { return }
        
        coverImageView.sd_setImage(with: URL(string: coverLink))
        titleLabel.text = track.title
        artistLabel.text = artist
    }
    
    @IBAction func playPauseButtonDidTap(_ sender: Any) {
        if AudioPlayer.player.rate == 0 {
            AudioPlayer.pauseDidTap()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            AudioPlayer.playDidTap()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    @IBAction func nextTrackDidTap(_ sender: Any) {
        AudioPlayer.playNextTrack()
    }
}

extension NowPlayingView: AudioPlayerDelegate {
    func nextTrackDidTap() {
        set()
    }
    
    func previousTrackDidTap() {
        set()
    }
    
    func setupView() {
        guard let currentTime = AudioPlayer.player.currentItem?.currentTime().seconds,
              let duration = AudioPlayer.player.currentItem?.duration.seconds
        else { return }
        
        if AudioPlayer.player.rate == 0 {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        
        durationProgressView.setProgress(Float(currentTime / duration), animated: true)
    }
}
