//
//  ViewControllerExtension.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 03-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: Header
        
    func setupHeader(with text:String, height: CGFloat) -> UIView {
        
        let header = UIView()
        header.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: height)
        header.backgroundColor = UIColor.customGray
        
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 0, width: self.view.frame.size.width - 40, height: height)
        label.textAlignment = .left
        label.font = UIFont(name: "HelveticaNeue-thin", size: 16)
        label.text = text
        header.addSubview(label)
        
        return header
    }
    
    func setupHeaderButton(for header:UIView, with text:String) -> UIButton {
        let button:UIButton = UIButton()
        button.frame = CGRect(x: header.frame.size.width - 120, y: 0, width: 100, height: header.frame.size.height)
        button.contentHorizontalAlignment = .right
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-thin", size: 12)
        button.setTitleColor(.black, for: .normal)
        return button
    }
        
    // MARK: Refresher
    
    func createRefresher() -> UIRefreshControl {
        let refresher:UIRefreshControl = self.setupRefresher(for: "Pull to refresh")
        refresher.addTarget(self, action: #selector(self.refresherChanged(_:)), for: .valueChanged)
        
        return refresher
    }
    
    func setupRefresher(for title:String) -> UIRefreshControl {
        
        let attributes = [NSForegroundColorAttributeName:UIColor.black]
        let attributedTitle:NSAttributedString = NSAttributedString(string: title, attributes: attributes)
        
        let refresher:UIRefreshControl
        
        if let refreshControl = self.view.window?.viewWithTag(1) {
            refresher = refreshControl as! UIRefreshControl
        } else {
            refresher = UIRefreshControl()
            refresher.tag = 1
        }
        
        refresher.attributedTitle = attributedTitle
        return refresher
    }
    
    func hideRefresher(_ refresher:UIRefreshControl) {
        let attributes = [NSForegroundColorAttributeName:UIColor.black]
        let attributedTitle:NSAttributedString = NSAttributedString(string: "Pull to refresh", attributes: attributes)
        
        refresher.endRefreshing()
        refresher.attributedTitle = attributedTitle
    }
    
    @objc func refresherChanged(_ refresher:UIRefreshControl) {
        let attributes = [NSForegroundColorAttributeName:UIColor.black]
        let attributedTitle:NSAttributedString = NSAttributedString.init(string: "Refreshing data..", attributes: attributes)
        refresher.attributedTitle = attributedTitle
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.hideRefresher(refresher)
        })
    }
    
    // MARK: Loader
    
    func setupLoader() {
        let window = UIApplication.shared.keyWindow!
        
        if window.viewWithTag(9) == nil {
            let loader:Loader = Loader()
            window.addSubview(loader)
        }
    }
    
    func showLoader() {
        self.setupLoader()
        let loader = UIApplication.shared.keyWindow?.viewWithTag(9)
        loader?.alpha = 1
    }
    
    func hideLoader() {
        let loader = UIApplication.shared.keyWindow?.viewWithTag(9)
        
        UIView.animate(withDuration: 0.3, animations: {
            loader?.alpha = 0
        }) { (success) in
            loader?.removeFromSuperview()
        }
    }
    
    // MARK: Navigation
    @objc func goToPreviousController() {
        self.navigationController?.popViewController(animated: true)
    }

        
}

