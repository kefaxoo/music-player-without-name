//
//  MenuActionsEnum.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import UIKit

enum MenuActionsEnum: String {
    case addToLibrary = "Add to library"
    case removeFromLibrary = "Remove from library"
    case shareSong = "Share song"
    case shareLink = "Share link"
    
    var image: UIImage? {
        switch self {
            case .addToLibrary:
                return UIImage(systemName: "heart")
            case .removeFromLibrary:
                return UIImage(systemName: "heart.slash.fill")
            case .shareSong:
                return UIImage(systemName: "music.note")
            case .shareLink:
                return UIImage(systemName: "square.and.arrow.up")
        }
    }
}
