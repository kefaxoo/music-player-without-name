//
//  ViewController.swift
//  music-app
//
//  Created by Bahdan Piatrouski on 20.01.23.
//

import UIKit
import AVKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []) else { return }
        
        configureTabBar()
        createCacheDirectory()
    }
    
    private func createCacheDirectory() {
        var path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "Music")
        if let stringPath = path?.path,
           let path,
           !FileManager.default.fileExists(atPath: stringPath) {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "Artworks")
        if let stringPath = path?.path,
           let path,
           !FileManager.default.fileExists(atPath: stringPath) {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func configureNavigationController(vc: UIViewController, title: String? = nil) -> UINavigationController {
        if let title {
            vc.navigationItem.title = title
        }
        
        let nc = UINavigationController(rootViewController: vc)
        nc.navigationBar.prefersLargeTitles = true
        return nc
    }
    
    private func configureTabBar() {
        let searchVC = SearchController(nibName: SearchController.id, bundle: nil)
        searchVC.tabBarItem = UITabBarItem(title: Localization.TabBar.search.rawValue.localized, image: UIImage(systemName: "magnifyingglass"), tag: 1001)
        
        let libraryVC = LibraryController(nibName: LibraryController.id, bundle: nil)
        libraryVC.tabBarItem = UITabBarItem(title: Localization.TabBar.library.rawValue.localized, image: UIImage(systemName: "heart"), selectedImage: UIImage(systemName: "heart.fill"))
        
//        let recognizeLinkVC = RecognizeLinkController(nibName: RecognizeLinkController.id, bundle: nil)
//        recognizeLinkVC.tabBarItem = UITabBarItem(title: "Recognize", image: UIImage(systemName: "text.viewfinder"), tag: 1003)
        
        self.viewControllers = [configureNavigationController(vc: libraryVC, title: Localization.TabBar.library.rawValue.localized), configureNavigationController(vc: searchVC, title: Localization.TabBar.search.rawValue.localized)]
        self.tabBar.tintColor = .systemPurple
    }
    
    static var activeNavVC: UINavigationController? = {
        guard let tabBarVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? UITabBarController else { return nil }
            
        if let currentNavVC = tabBarVC.selectedViewController as? UINavigationController {
            return currentNavVC
        }
        
        return nil
    }()
}

