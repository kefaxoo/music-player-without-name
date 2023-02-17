//
//  Bundle.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 17.02.23.
//

import Foundation

extension Bundle {
    private static var bundle: Bundle!
    
    static func localizedBundle() -> Bundle! {
        let locale = Locale.current.language.languageCode?.identifier
        
        if bundle == nil {
            let path = Bundle.main.path(forResource: locale, ofType: "lproj")
            bundle = Bundle(path: path!)
        }
        
        return bundle
    }
}
