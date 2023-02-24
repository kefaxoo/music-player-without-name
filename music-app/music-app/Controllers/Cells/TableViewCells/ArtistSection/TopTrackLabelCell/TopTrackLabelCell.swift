//
//  TopTrackLabelCell.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 19.02.23.
//

import UIKit
import SPAlert

class TopTrackLabelCell: UITableViewCell {

    @IBOutlet weak var tracksButton: UIButton!
    
    static let id = String(describing: TopTrackLabelCell.self)
    
    weak var delegate: ViewControllerDelegate?
    
    private var artist: DeezerArtist?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLocale()
    }
    
    private func setLocale() {
        tracksButton.setTitle(Localization.Controller.Artist.TopTrackLabelCell.title.rawValue.localized, for: .normal)
    }
    
    func set(_ artist: DeezerArtist) {
        self.artist = artist
    }
    
    @IBAction func tracksButtonDidTap(_ sender: Any) {
        guard let delegate,
              let artist
        else { return }
        let alert = SPAlertView(title: "", preset: .spinner)
        alert.dismissByTap = false
        alert.present()
        
        DeezerProvider.getArtistTracks(artist.id, limitTracks: 25) { tracks in
            let tracksVC = TracksController()
            tracksVC.set(tracks)
            tracksVC.navigationItem.title = Localization.Controller.Artist.TopTrackLabelCell.title.rawValue.localized
            alert.dismiss()
            delegate.pushVC(tracksVC)
        } failure: { error in
            alert.dismiss()
            let alert = SPAlertView(title: Localization.Alert.Title.error.rawValue, message: error, preset: .error)
            alert.present(haptic: .error)
        }
    }
    
}
