//
//  RegisterViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 07-08-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        usernameTextfield.delegate = self
    }
    
    func getName() -> String {
        return usernameTextfield.text!
    }
    
    func getDateOfBirth() -> String {
        return datePicker.date.toDateString()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let name = getName()
        let birth = getDateOfBirth()
        
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(name, forKey: "userName")
        defaults.set(birth, forKey: "userDateOfBirth")
        defaults.set(true, forKey: "isRegistered")
    }
    
    //Mark: Textfield delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



