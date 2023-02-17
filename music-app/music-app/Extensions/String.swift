//
//  String.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 13.02.23.
//

import Foundation

extension String {
    var year: Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: self) else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        guard let year = components.year else { return nil }
        return year
    }
    
    var toUnixFilename: String {
        let removeChars: Set<Character> = ["/", ">", "<", "|", ":", "&"]
        var newSelf = self
        newSelf.removeAll(where: { removeChars.contains($0) })
        return newSelf
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: Bundle.localizedBundle(), value: self, comment: self)
    }
    
    func localizedWithParameters(title: String, artist: String, link: String) -> String {
        return String(format: self.localized, title, artist, link)
    }
}
