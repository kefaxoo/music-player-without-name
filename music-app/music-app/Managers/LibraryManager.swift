//
//  LibraryManager.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import Foundation

final class LibraryManager {
    static func isTrackInLibrary(_ trackID: Int) -> Bool {
        let tracks = RealmManager<LibraryTrack>().read()
        
        return tracks.contains { $0.id == trackID }
    }
}
