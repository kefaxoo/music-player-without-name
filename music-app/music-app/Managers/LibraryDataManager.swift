//
//  LibraryDataManager.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 5.03.23.
//

import Foundation

final class LibraryDataManager {
    private static var manager = UserDefaults.standard
    
    final class Songs {
        static var alphabetSort: Bool {
            get {
                manager.value(forKey: #function) as? Bool ?? false
            }
            set {
                manager.set(newValue, forKey: #function)
            }
        }
        
        static var reversedAlphabetSort: Bool {
            get {
                manager.value(forKey: #function) as? Bool ?? false
            }
            set {
                manager.set(newValue, forKey: #function)
            }
        }
        
        static var recentlyAddedSort: Bool {
            get {
                manager.value(forKey: #function) as? Bool ?? true
            }
            set {
                manager.set(newValue, forKey: #function)
            }
        }
    }
}
