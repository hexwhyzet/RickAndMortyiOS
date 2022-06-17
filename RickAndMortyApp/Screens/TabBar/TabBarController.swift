//
//  TabBarController.swift
//  RickAndMortyApp
//
//  Created by Ваня on 07.06.2022.
//

import UIKit

class TabBar: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var delta: CGFloat
        if self.tabBar.safeAreaInsets.bottom == 0 {
            delta = 10
        } else {
            delta = 30
        }
        
        tabBar.frame.size.height += delta
        tabBar.frame.origin.y = view.frame.height - tabBar.frame.size.height
        
        self.children.forEach {
            $0.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: delta, right: 0)
        }
    }
    
    func setupUI() {
        viewControllers = [
            createNavController(for: HomeViewController(),
                                title: "",
                                image: UIImage(systemName: "house")!,
                                selected: UIImage(systemName: "house")!),
            createNavController(for: FavouritesViewController(),
                                title: "",
                                image: UIImage(systemName: "heart")!,
                                selected: UIImage(systemName: "heart.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))!),
            createNavController(for: UIViewController(),
                                title: "",
                                image: UIImage(systemName: "magnifyingglass")!,
                                selected: UIImage(systemName: "magnifyingglass")!),
        ]
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController,
                                         title: String,
                                         image: UIImage,
                                         selected: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        navController.tabBarItem.selectedImage = selected
        navController.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        return navController
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == viewControllers![2] {
            logger.log(level: .info, message: "\(self): search tab opened")
            let vc = SearchViewController()
            present(vc, animated: true)
            return false
        } else {
            if viewController == viewControllers![0] {
                logger.log(level: .info, message: "\(self): home tab opened")
            } else {
                logger.log(level: .info, message: "\(self): favourites tab opened")
            }
            
            return true
        }
    }
}
