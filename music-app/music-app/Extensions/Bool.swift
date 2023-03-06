//
//  Bool.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 5.03.23.
//

import UIKit

extension Bool {
    var getState: UIMenuElement.State {
        return self ? .on : .off
    }
}
