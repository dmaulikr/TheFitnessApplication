//
//  DetailTableViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 03-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    
    var modalView:Modal?
    
    // MARK: - Variables
    
    var exercize:Exercize!
    var selectedSet:Set?
    var modalPosition:CGFloat!
    var dates:[String] = []
    var allSets:[ [Set] ] = []
    
    var isLoading:Bool = false
    
    
    // MARK: - General
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        self.setupNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showLoader()
        isLoading = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadTableData()
    }
    
    // MARK: - Navigation
    
    func setupNavigation() {
        self.title = exercize.name
        
        let backButton:NavigationButton = NavigationButton(image: "back_icon", position: .left)
        backButton.addTarget(self, action: #selector(self.goToPreviousController), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonClicked))
    }
    
    @objc func addButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "AddExercize", sender: nil)
    }
    
    // MARK: Refresher
    
    override func refresherChanged(_ refresher: UIRefreshControl) {
        self.loadTableData()
        super.refresherChanged(refresher)
    }
    
    // MARK: Modals
    
    func showModal(message: String, btnText: String) {
        let window:UIWindow = UIApplication.shared.keyWindow!
        let modal:Modal = Modal(with: message, button: "ALRIGHT!")
        window.addSubview(modal)
    }
    
    func showEditModal(set:Set) {
        selectedSet = set
        
        let message = "Within this modal you can modify the weight and reps of your set"
        modalView = Modal(with: message, textfield: "\(set.reputition)x", textfield2: "\(set.weight)kg", button: "SAVE IT")
        modalView?.buttonComponent.removeTarget(nil, action: nil, for: .allEvents)
        modalView?.buttonComponent.addTarget(self, action: #selector(self.update), for: .touchUpInside)
        modalView?.textfieldComponent!.delegate = self
        modalView?.textfieldComponent?.keyboardType = .numberPad
        modalView?.textfieldComponent2!.delegate = self
        modalView?.textfieldComponent2?.keyboardType = .numberPad
        self.view.window?.addSubview(modalView!)
    }
    
    func showDeleteModal(set:Set) {
        selectedSet = set
        
        let warning = "Are you sure you want to delete \(set.reputition)x \(set.weight)kg ?"
        modalView = Modal(warning: warning, button: "DELETE IT")
        modalView?.buttonComponent.removeTarget(nil, action: nil, for: .allEvents)
        modalView?.buttonComponent.addTarget(self, action: #selector(self.remove), for: .touchUpInside)
        self.view.window?.addSubview(modalView!)
    }
    
    // MARK: Actions
    
    @objc func update() {
        var repString = modalView!.textfieldComponent!.text!
        repString = removeCharFrom(string: repString, char: "x")
        let rep:Int = Int(repString)!
        
        var weightString = modalView!.textfieldComponent2!.text!
        weightString = removeCharFrom(string: weightString, char: "kg")
        let weight:Int = Int(weightString)!
        
        if rep > 0 {
            SetHelper.sharedInstance.update(set: selectedSet!, rep:rep, weight:weight, completionHandler: { (succes, error) in
                self.loadTableData()
                self.modalView?.hideModal()
                
                let experience:Int = (selectedSet?.weight)! * (selectedSet?.reputition)!
                selectedSet = nil;
                let experienceNew:Int = weight * rep
                let difference:Int = experienceNew - experience
                PlayerHelper.sharedInstance.addToHighscore(points: difference, completionHandler: { (score) in
                    let defaults:UserDefaults = UserDefaults.standard
                    if defaults.bool(forKey: "ShowPointsModal") == true {
                        var message = "You've gained \(difference) points. Your total score is updated to \(score) points!"
                        if difference < 0 {
                            message = "You lost \(difference * -1) points. Your total score is updated to \(score) points!"
                        }
                        self.showModal(message: message, btnText: "ALRIGHT!")
                    }
                })
            })
        }
    }
    
    @objc func remove() {
        SetHelper.sharedInstance.destroy(set: selectedSet!, completionHandler: { (success, error) in
            let experience:Int = (selectedSet?.weight)! * (selectedSet?.reputition)!
            selectedSet = nil;
            self.loadTableData()
            self.modalView?.removeFromSuperview()
            
            PlayerHelper.sharedInstance.addToHighscore(points: experience * -1, completionHandler: { (score) in
                let defaults:UserDefaults = UserDefaults.standard
                if defaults.bool(forKey: "ShowPointsModal") == true {
                    let message = "You lost \(experience) points. Your total score is updated to \(score) points!"
                    self.showModal(message: message, btnText: "ALRIGHT!")
                }
            })
            
        })
    }
    
    // MARK:  Helpers
    
    func getMonthName(from dateString:String ) -> String {
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dateString)!
        
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.day, .month], from: date)
        let day = comp.day
        let month = comp.month
        
        let monthName = DateFormatter().monthSymbols[month! - 1]
        
        return "\(day!) " + monthName
    }
    
    func removeCharFrom(string: String, char: String) -> String {
        return string.replacingOccurrences(of: char, with: "")
    }
    
    // MARK: - TableView
    
    func setupTableView() {
        self.tableView.backgroundColor = UIColor.customGray
        self.tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        self.tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "EmptyTableViewCell")
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let refresher:UIRefreshControl = self.createRefresher()
        self.tableView.addSubview(refresher)
        
        loadTableData()
    }
    
    func loadTableData() {
        dates = []
        allSets = []
        
        let sets = SetHelper.sharedInstance.getAllSets(for: exercize.id)
        for set in sets {
            if !dates.contains(set.date.toDateString()) {
                dates.append(set.date.toDateString())
            }
        }
        
        for date in dates {
            let setArray = sets.filter({ $0.date.toDateString() == date })
            allSets.append(setArray)
        }
        
        isLoading = false
        self.tableView.reloadData()
        hideLoader()
    }
    
    func tableViewIsEmpty() -> Bool {
        for setArray in allSets {
            if setArray.count > 0 { return false }
        }
        return true
    }
    
    func renderEmptyCell(for indexPath:IndexPath) -> EmptyTableViewCell {
        let cell:EmptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell", for: indexPath) as! EmptyTableViewCell
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
        cell.render(for: "No results found!")
        return cell
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if dates.count == 0 { return 1 }
        return dates.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 0 }
        if tableViewIsEmpty() { return 1 }
        return allSets[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableViewIsEmpty() { return self.renderEmptyCell(for: indexPath) }
        
        self.tableView.isScrollEnabled = true
        self.tableView.separatorStyle = .singleLine
        
        let cell:MainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        let set:Set = allSets[indexPath.section][allSets[indexPath.section].count  - (indexPath.row + 1)]
        let string = "\(indexPath.row + 1). \(set.reputition)x \(set.weight)kg"
        cell.render(for: string, sub: "\(set.reputition * set.weight) points")
        cell.cellSubLabel.textColor = UIColor.customDarkGray
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isLoading { return 1 }
        if tableViewIsEmpty() { return 0.1 }
        return 36
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isLoading { return nil }
        if tableViewIsEmpty() { return nil }
        
        let datestring:String = dates[section]
        let month = self.getMonthName(from: datestring)
        return self.setupHeader(with: month, height:36)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit:UITableViewRowAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let rows = self.tableView.numberOfRows(inSection: indexPath.section) - 1
            let set:Set = self.allSets[indexPath.section][rows - indexPath.row]
            self.showEditModal(set: set)
        }
        
        let delete:UITableViewRowAction = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let rows = self.tableView.numberOfRows(inSection: indexPath.section) - 1
            let set:Set = self.allSets[indexPath.section][rows - indexPath.row]
            self.showDeleteModal(set: set)
        }
        
        edit.backgroundColor = UIColor.darkGray
        delete.backgroundColor = UIColor.customRed
        return [edit, delete] 
    }
    
    // MARK: Textfield delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if modalPosition == nil { modalPosition = (self.modalView?.frame.origin.y)! }
        
        UIView.animate(withDuration: 0.3) {
            self.modalView?.frame = CGRect(
                x: (self.modalView?.frame.origin.x)!,
                y: self.modalPosition - 100,
                width: (self.modalView?.frame.size.width)!,
                height: (self.modalView?.frame.size.height)!)
        }
        
        if textField.tag == 1 {
            if textField.text?.contains("x") == true {
                textField.text = textField.text?.replacingOccurrences(of: "x", with: "")
            }
        }
        else {
            if textField.text?.contains("kg") == true {
                textField.text = textField.text?.replacingOccurrences(of: "kg", with: "")
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" { textField.text = "0" }
        
        if textField.tag == 1 {
            if textField.text?.contains("x") == false {
                textField.text = textField.text! + "x"
            }
        }
        else {
            if textField.text?.contains("kg") == false {
                textField.text = textField.text! + "kg"
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddExercize" {
            let vc:AddTableViewController = segue.destination as! AddTableViewController
            vc.exercize = exercize
        }
    }
    
    
}

