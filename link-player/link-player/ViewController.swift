//
//  ViewController.swift
//  link-player
//
//  Created by Bahdan Piatrouski on 17.04.23.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var durationLabel: UILabel!
    
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.volume = 1
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func playAction(_ sender: Any) {
        guard let link = linkTextField.text,
              let url = URL(string: link)
        else { return }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 600), queue: .main) { _ in
            guard let currentTime = self.player.currentItem?.currentTime().seconds else { return }
            
            self.durationLabel.text = "Current time: \(round(currentTime))"
        }
    }
}

