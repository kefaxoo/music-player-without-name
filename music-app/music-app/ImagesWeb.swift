//
//  Images.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 31.01.23.
//

import Foundation
import UIKit
import SDWebImage

final class ImagesWeb {
    func downloadImage(link: String) -> UIImage {
        guard let url = URL(string: link) else { return UIImage() }
        
        var downloadedImage = UIImage()
        UIImageView().sd_setImage(with: url, completed: { image, _, _, _ in
            if let image {
                downloadedImage = image
            }
        })
        
        return downloadedImage
    }
}
