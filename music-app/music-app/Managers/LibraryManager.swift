//
//  LibraryManager.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.02.23.
//

import Foundation

final class LibraryManager {
    static func isTrackInLibrary(_ trackID: Int) -> Bool {
        return RealmManager<LibraryTrack>().read().contains { $0.id == trackID }
    }
    
    static func isTrackIsDownloaded(_ track: DeezerTrack) -> Bool {
        guard let artist = track.artist?.name,
              let album = track.album?.title,
              let path = getAbsolutePath(filename: "Music/\(artist.toUnixFilename) - \(track.title.toUnixFilename) - \(album.toUnixFilename).mp3", path: .documentDirectory)?.path
        else { return false }
        
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func trackInLibrary(_ trackID: Int) -> LibraryTrack? {
        return RealmManager<LibraryTrack>().read().first(where: {$0.id == trackID })
    }
    
    static func getAbsolutePath(filename: String, path: FileManager.SearchPathDirectory) -> URL? {
        let path = FileManager.default.urls(for: path, in: .userDomainMask).first
        
        return path?.appending(path: filename)
    }
}
