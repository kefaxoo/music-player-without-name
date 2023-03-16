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
    
    static func isTrackDownloaded(artist: String, title: String, album: String) -> Bool {
        let filename = "\(artist) - \(title) - \(album).mp3".toUnixFilename
        
        guard let path = getAbsolutePath(filename: "Music/\(filename)", path: .documentDirectory)?.path else { return false }
        
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func isCoverDownloaded(artist: String, album albumTitle: String) -> Bool {
        let filename = "Artworks/\("\(artist) - \(albumTitle).jpg".toUnixFilename)"
        
        guard let path = getAbsolutePath(filename: filename, path: .documentDirectory)?.path else { return false }
        
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func trackInLibrary(_ trackID: Int) -> LibraryTrack? {
        return RealmManager<LibraryTrack>().read().first(where: {$0.id == trackID })
    }
    
    static func getAbsolutePath(filename: String, path: FileManager.SearchPathDirectory) -> URL? {
        let path = FileManager.default.urls(for: path, in: .userDomainMask).first
        
        return path?.appending(path: filename)
    }
    
    static func downloadArtworks() {
        RealmManager<LibraryTrack>().read().forEach { track in
            if track.coverLink.isEmpty {
                DeezerProvider.getAlbum(track.albumID) { album in
                    guard let artist = album.artist?.name else { return }
                    
                    let filename = "\(artist) - \(album.title)".toUnixFilename
                    let directory = "Artworks/\(filename).jpg"
                    if let url = URL(string: album.coverBig),
                       let directoryURL = LibraryManager.getAbsolutePath(filename: directory, path: .documentDirectory)
                    {
                        URLSession.shared.dataTask(with: url) { imageData, response, error in
                            guard let imageData else { return }
                            
                            do {
                                try imageData.write(to: directoryURL)
                                DispatchQueue.main.async {
                                    RealmManager<LibraryTrack>().update { realm in
                                        try? realm.write {
                                            track.coverLink = directory
                                        }
                                    }
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }.resume()
                    }
                } failure: { error in
                    print(error)
                }

            }
        }
    }
    
    static func isTrackInPlaylist(trackID: Int, playlistID: String) -> Bool {
        var isTrackInPlaylist = false
        
        RealmManager<LibraryTrackInPlaylist>().read().forEach { track in
            if track.id == trackID, track.playlistID == playlistID {
                isTrackInPlaylist = true
            }
        }
        
        return isTrackInPlaylist
    }
}
