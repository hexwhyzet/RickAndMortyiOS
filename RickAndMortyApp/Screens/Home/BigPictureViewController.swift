//
//  BigPictureView.swift
//  RickAndMortyApp
//
//  Created by Ваня on 13.06.2022.
//

import Foundation
import UIKit

class BigPictureViewController : UIViewController, UIScrollViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.appColor(.bg)
        
        scrollView.delegate = self
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        let vWidth = self.view.frame.width
        let vHeight = self.view.frame.height
        
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: vWidth, height: vHeight)
        imageView.frame = CGRect(x: 0, y: 0, width: vWidth, height: vHeight)
        
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let padding: CGFloat = 16
        let buttonSize: CGFloat = 50
        closeButton.layer.cornerRadius = buttonSize / 2
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            closeButton.widthAnchor.constraint(equalToConstant: buttonSize),
            closeButton.heightAnchor.constraint(equalToConstant: buttonSize),
        ])
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    private let imageView: UIImageView = {
        let ret = UIImageView(image: UIImage(named: "RickAndMortyList.png"))
        ret.contentMode = .scaleToFill
        return ret
    }()
    
    private let scrollView: UIScrollView = {
        let ret = UIScrollView()
        ret.minimumZoomScale = 1.0
        ret.maximumZoomScale = 4.0
        ret.alwaysBounceVertical = false
        ret.alwaysBounceHorizontal = false
        ret.showsVerticalScrollIndicator = false
        ret.flashScrollIndicators()
        return ret
    }()
    
    @objc func closeButtonAction() {
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    private let closeButton: UIButton = {
        let ret = UIButton()
        ret.setImage(UIImage(systemName: "xmark"), for: .normal)
        ret.tintColor = UIColor.appColor(.main)
        ret.backgroundColor = UIColor.appColor(.greybg)
        ret.addTarget(self, action:#selector(closeButtonAction), for: .touchUpInside)
        return ret
    }()
}
