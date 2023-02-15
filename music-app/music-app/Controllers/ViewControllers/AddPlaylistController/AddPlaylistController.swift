//
//  AddPlaylistController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 15.02.23.
//

import UIKit
import SPAlert

class AddPlaylistController: UIViewController {

    @IBOutlet weak var playlistNameTextField: UITextField!
    @IBOutlet weak var playlistImageView: UIImageView!
    @IBOutlet weak var addImageView: UIImageView!
    
    private var tracks = [LibraryTrackInPlaylist]()
    
    var reloadClosure: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGestures()
    }
    
    private func setGestures() {
        addImageView.isUserInteractionEnabled = true
        addImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setImage)))
        playlistImageView.isUserInteractionEnabled = true
        playlistImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setImage)))
    }
    
    @objc private func setImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func dismissViewControllerAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func createPlaylistAction(_ sender: Any) {
        guard let playlistName = playlistNameTextField.text else { return }
        
        if playlistName.isEmpty {
            let alertView = SPAlertView(title: "Error", message: "Unavailable to create playlist", preset: .error)
            alertView.present(haptic: .error)
            return
        }
        
        var isExplicit = false
        tracks.forEach { track in
            if track.isExplicit {
                isExplicit = true
            }
        }
        
        let playlist = LibraryPlaylist(id: UUID().uuidString, image: saveImage(playlistName), name: playlistName, isExplicit: isExplicit)
        RealmManager<LibraryPlaylist>().write(object: playlist)
        let alertView = SPAlertView(title: "Success", preset: .done)
        alertView.present(haptic: .success)
        reloadClosure?()
        self.dismiss(animated: true)
        
    }
    
    private func saveImage(_ playlistName: String) -> String {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let pngData = playlistImageView.image?.pngData(),
           let filePath = path?.appendingPathComponent("Playlist-\(playlistName).png") {
            try? pngData.write(to: filePath)
            return filePath.absoluteString
        }
        
        return ""
    }
    
}

extension AddPlaylistController: UINavigationControllerDelegate {
    
}

extension AddPlaylistController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)
        addImageView.isHidden = true
        playlistImageView.image = image
    }
}
