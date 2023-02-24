//
//  Double.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 24.02.23.
//

import Foundation

extension Double {
    var time: String {
        if self.isNaN {
            return "00:00"
        }
        
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
}
