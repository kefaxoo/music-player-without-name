//
//  NowPlayingView.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 25.02.23.
//

import UIKit
import SDWebImage
import SPAlert

class NowPlayingView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var durationProgressView: UIProgressView!
    @IBOutlet weak var nextTrackButton: UIButton!
    
    private var track: DeezerTrack?
    
    deinit {
        print("deinit")
        print(contentView)
    }
    
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
        setInterface()
    }
    
    func setInterface() {
        playPauseButton.tintColor = SettingsManager.getColor.color
        nextTrackButton.tintColor = SettingsManager.getColor.color
        durationProgressView.tintColor = SettingsManager.getColor.color
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
