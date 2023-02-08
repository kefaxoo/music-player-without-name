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
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1001)
        
        let libraryVC = LibraryController(nibName: LibraryController.id, bundle: nil)
        libraryVC.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "heart"), selectedImage: UIImage(systemName: "heart.fill"))
        
//        let recognizeLinkVC = RecognizeLinkController(nibName: RecognizeLinkController.id, bundle: nil)
//        recognizeLinkVC.tabBarItem = UITabBarItem(title: "Recognize", image: UIImage(systemName: "text.viewfinder"), tag: 1003)
        
        self.viewControllers = [configureNavigationController(vc: libraryVC, title: "Library"), configureNavigationController(vc: searchVC, title: "Search")]
        self.tabBar.tintColor = .purple
    }
    
    static var activeNavVC: UINavigationController? = {
        guard let tabBarVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController as? UITabBarController else { return nil }
            
        if let currentNavVC = tabBarVC.selectedViewController as? UINavigationController {
            return currentNavVC
        }
        
        return nil
    }()
}

