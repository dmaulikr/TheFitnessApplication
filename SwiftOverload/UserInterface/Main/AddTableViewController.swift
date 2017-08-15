//
//  AddTableViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 05-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class AddTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    
    var modalView:Modal?
    
    // MARK: - Variables
    
    var maxRows:Int = 4
    var toolbar:UIView!
    var exercize:Exercize!
    var repArray:[ Int ] = []
    var weightArray:[ Int ] = []
    
    var keyboardHeight:CGFloat?
    
    // MARK: - General
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupTableView()
        setupTapGesture()
        setupToolbar()
    }
    
    // MARK: - Gestures
    
    func setupTapGesture() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    func setupNavigation() {
        self.title = "Add"
        let backButton:NavigationButton = NavigationButton(image: "back_icon", position: .left)
        backButton.addTarget(self, action: #selector(self.goToPreviousController), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.addButtonClicked))
    }
    
    @objc func addButtonClicked() {
        var points:Int = 0
        var allPoints:Int = 0
        
        view.endEditing(true)
        
        DatabaseHelper.sharedInstance.openDatabase()
        
        for i in 0..<repArray.count {
            let rep:Int = repArray[i]
            let weight:Int = weightArray[i]
            
            let date:Date = Date().addingTimeInterval(TimeInterval(i))
            
            if rep > 0 {
                SetHelper.sharedInstance.create(
                    for: exercize.id,
                    rep: rep,
                    weight: weight,
                    date: date.toString(),
                    completionHandler: { (finished) in
                        print("Set is succesfully inserted")
                })
                
                let score = weight * rep
                points += score
                
                PlayerHelper.sharedInstance.addToHighscore(points: score, completionHandler: { (highscore) in
                    allPoints = highscore
                })
            }
        }
        
        DatabaseHelper.sharedInstance.closeDatabase()
        
        let defaults:UserDefaults = UserDefaults.standard
        if defaults.bool(forKey: "ShowPointsModal") == true {
            showModal(points, allPoints)
        }
        
        self.goToPreviousController()
    }
    
    func showModal(_ points:Int, _ highscore:Int ) {
        let window:UIWindow = UIApplication.shared.keyWindow!
        modalView = Modal(with: "You've earned \(points) points. Your total score is updated to \(highscore) points!", button: "NEAT!")
        window.addSubview(modalView!)
    }
    
    // MARK: Toolbar
    
    func setupToolbar() {
        toolbar = UIView()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50)
        toolbar.backgroundColor = UIColor.customDarkGray
        
        let cancelButton:UIButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 120, y: 0, width: 100, height: 50))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.contentHorizontalAlignment = .right
        cancelButton.addTarget(self, action: #selector(self.hideKeyboard), for: .touchUpInside)
        toolbar.addSubview(cancelButton)
    }
    
    // MARK: - Table View
    
    func setupTableView() {
        
        for _ in 0..<maxRows {
            weightArray.append(0)
            repArray.append(0)
        }
        
        self.tableView.backgroundColor = UIColor.customGray
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0)
        self.tableView.register(UINib(nibName: "AddTableViewCell", bundle: nil), forCellReuseIdentifier: "AddTableViewCell")
        self.tableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "ButtonTableViewCell")
    }
    
    @objc func addRowToTableView() {
        maxRows += 1
        weightArray.append(0)
        repArray.append(0)
        
        self.tableView.reloadData()
        self.scrollToLastRow()
    }
    
    func scrollToLastRow() {
        let indexPath:IndexPath = IndexPath(row: 0, section: maxRows - 1)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        let cell:AddTableViewCell = self.tableView.cellForRow(at: indexPath) as! AddTableViewCell
        let textfield:UITextField = cell.viewWithTag(2) as! UITextField
        textfield.becomeFirstResponder()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return maxRows + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == maxRows {
            let cell:ButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ButtonTableViewCell", for: indexPath) as! ButtonTableViewCell
            cell.render(for: "Add row")
            cell.cellButton.addTarget(self, action: #selector(self.addRowToTableView), for: .touchUpInside)
            return cell
        }
        
        let cell:AddTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AddTableViewCell", for: indexPath) as! AddTableViewCell
        cell.render(for: indexPath)
        cell.weightTextField.delegate = self
        
        cell.reputitionTextField.delegate = self
        let rep = repArray[indexPath.section]
        var repStr = "\(rep)"
        if rep == 0 { repStr = "" }
        cell.reputitionTextField.text = repStr
        
        let weight = weightArray[indexPath.section]
        var weightStr = "\(weight)"
        if rep == 0 && weight == 0 { weightStr = "" }
        cell.weightTextField.text = weightStr
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == maxRows { return 10 }
        return 35
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == maxRows { return self.setupHeader(with: "", height: 10) }
        
        let header:UIView = self.setupHeader(with: "Set #\(section + 1)", height: 35)
        return header
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.hideKeyboard()
    }
    
    // MARK: Textfields
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = toolbar
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let indexPath = self.tableView.indexPath(for: textField.superview?.superview?.superview as! UITableViewCell) {
            var value = 0
            
            if textField.text != "" && textField.text != nil {
                value = Int(textField.text!)!
            }
            
            if textField.tag == 1 {
                weightArray[indexPath.section] = value
            }
            else {
                repArray[indexPath.section] = value
            }
        }
    }
    
}



