//
//  Int.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 18.02.23.
//

import Foundation

extension Int {
    var durationInMinutes: String {
        let minutes = self / 60 % 60
        
        return "\(minutes) minute\(minutes > 1 ? "s": "")"
    }
}
