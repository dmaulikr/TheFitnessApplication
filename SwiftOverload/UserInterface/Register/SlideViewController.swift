//
//  SlideViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 08-08-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class SlideViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func slideToNext() {
        // TODO: Slide to next slide!
    }
    
    @IBAction func goToNextPage(_ sender: Any) {
        self.performSegue(withIdentifier: "next", sender: nil)
    }
    
}

