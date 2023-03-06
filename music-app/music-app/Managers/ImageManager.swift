//
//  ImageManager.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 6.03.23.
//

import UIKit

final class ImageManager {
    static func loadLocalImage(_ directory: String) -> UIImage? {
        if let path = LibraryManager.getAbsolutePath(filename: directory, path: .documentDirectory),
           let imageData = try? Data(contentsOf: path) {
            return UIImage(data: imageData)
        }
        
        return nil
    }
    
    static func deleteLocalImage(_ directory: String) -> Bool {
        if let directoryURL = LibraryManager.getAbsolutePath(filename: directory, path: .documentDirectory) {
            do {
                try FileManager.default.removeItem(at: directoryURL)
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }
}
