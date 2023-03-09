//
//  SettingsManager.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 8.03.23.
//

import UIKit

final class SettingsManager {
    enum SettingType: CaseIterable {
        case color
    }
    
    enum ColorType: String, CaseIterable {
        case blue = "blueColor"
        case cyan = "cyanColor"
        case green = "greenColor"
        case indigo = "indigoColor"
        case mint = "mintColor"
        case orange = "orangeColor"
        case pink = "pinkColor"
        case purple = "purpleColor"
        case red = "redColor"
        case teal = "tealColor"
        case yellow = "yellowColor"
        
        var color: UIColor {
            switch self {
                case .blue:
                    return UIColor.systemBlue
                case .cyan:
                    return UIColor.systemCyan
                case .green:
                    return UIColor.systemGreen
                case .indigo:
                    return UIColor.systemIndigo
                case .mint:
                    return UIColor.systemMint
                case .orange:
                    return UIColor.systemOrange
                case .pink:
                    return UIColor.systemPink
                case .purple:
                    return UIColor.systemPurple
                case .red:
                    return UIColor.systemRed
                case .teal:
                    return UIColor.systemTeal
                case .yellow:
                    return UIColor.yellow
            }
        }
        
        var title: String {
            switch self {
                case .blue:
                    return Localization.Settings.Color.blue.rawValue.localized
                case .cyan:
                    return Localization.Settings.Color.cyan.rawValue.localized
                case .green:
                    return Localization.Settings.Color.green.rawValue.localized
                case .indigo:
                    return Localization.Settings.Color.indigo.rawValue.localized
                case .mint:
                    return Localization.Settings.Color.mint.rawValue.localized
                case .orange:
                    return Localization.Settings.Color.orange.rawValue.localized
                case .pink:
                    return Localization.Settings.Color.pink.rawValue.localized
                case .purple:
                    return Localization.Settings.Color.purple.rawValue.localized
                case .red:
                    return Localization.Settings.Color.red.rawValue.localized
                case .teal:
                    return Localization.Settings.Color.teal.rawValue.localized
                case .yellow:
                    return Localization.Settings.Color.yellow.rawValue.localized
            }
        }
    }
    
    private static var manager = UserDefaults.standard
    
    static func setColor(_ color: ColorType) {
        manager.set(color.rawValue, forKey: "colorSetting")
    }
    
    static var getColor: ColorType {
        return ColorType(rawValue: manager.value(forKey: "colorSetting") as? String ?? "") ?? ColorType.purple
    }
    
    static func isColorSelected(_ color: ColorType) -> UIMenuElement.State {
        return color == getColor ? UIMenuElement.State.on : UIMenuElement.State.off
    }
}
