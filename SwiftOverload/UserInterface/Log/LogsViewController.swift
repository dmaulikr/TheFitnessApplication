//
//  LogsViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 09-08-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate, ScrollCalendarDelegate {
    
    // Outlets
    
    var modalView:Modal?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: ExperienceHeaderView!
    
    
    // Variables
    
    var tableData:[ [Set] ] = []
    var exercizeNames:[String] = []
    var selectedSet:Set?
    var selectedDate:Date!
    var modalPosition:CGFloat!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        self.setupNavigation()
        self.setupHeaderView()
    }
    
    // MARK: Calendar
    
    func setupHeaderView() {
        
        headerView.pointsLabel.isHidden = true
        
        let calendarFrame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: headerView.frame.size.height)
        let calendar = ScrollCalendar(frame: calendarFrame)
        calendar.calendarDelegate = self
        calendar.isUserInteractionEnabled = true
        
        calendar.selectToday()
        selectedDate = calendar.getSelectedDate()
        loadData(for: selectedDate)
        
        headerView.addSubview(calendar)
    }
    
    func didSelectDate(date: Date) {
        selectedDate = date
        loadData(for: date)
    }
    
    func loadData(for date:Date) {
        self.tableData = []
        self.exercizeNames = []
        
        let sets:[Set] = SetHelper.sharedInstance.getAllSets(for: date)
        
        var exercises:[Int] = []
        
        for set in sets {
            if !exercises.contains(set.exercize) {
                exercises.append(set.exercize)
                let exercizeName = ExercizeHelper.sharedInstance.getExercizeName(for: set.exercize)
                exercizeNames.append(exercizeName)
            }
        }
        
        for exercize in exercises {
            let helper:[Set] = sets.filter({ $0.exercize == exercize})
            
            
            tableData.append(helper)
        }
        
        self.tableView.reloadData()
    }
        
    // MARK: Navigation
    
    func setupNavigation() {
        self.title = "History"
    }
    
    // MARK: Modals
    
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
        repString = repString.replacingOccurrences(of: "x", with: "")
        let rep:Int = Int(repString)!
        
        var weightString = modalView!.textfieldComponent2!.text!
        weightString = weightString.replacingOccurrences(of: "kg", with: "")
        let weight:Int = Int(weightString)!
        
        if rep > 0 {
            SetHelper.sharedInstance.update(set: selectedSet!, rep:rep, weight:weight, completionHandler: { (succes, error) in
                self.loadData(for: selectedDate)
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
                        let window:UIWindow = UIApplication.shared.keyWindow!
                        let modal:Modal = Modal(with: message, button: "ALRIGHT!")
                        window.addSubview(modal)
                    }
                    
                })
            })
        }
    }
    
    @objc func remove() {
        SetHelper.sharedInstance.destroy(set: selectedSet!, completionHandler: { (success, error) in
            let experience:Int = (selectedSet?.weight)! * (selectedSet?.reputition)!
            selectedSet = nil;
            self.loadData(for: selectedDate)
            self.modalView?.removeFromSuperview()
            
            PlayerHelper.sharedInstance.addToHighscore(points: experience * -1, completionHandler: { (score) in
                
                let defaults:UserDefaults = UserDefaults.standard
                if defaults.bool(forKey: "ShowPointsModal") == true {
                    let message = "You lost \(experience) points. Your total score is updated to \(score) points!"
                    let window:UIWindow = UIApplication.shared.keyWindow!
                    self.modalView = Modal(with: message, button: "ALRIGHT!")
                    window.addSubview(self.modalView!)
                }
                
            })
            
        })
    }
    
    // MARK: Table view
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.customGray
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: false)
        self.tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        self.tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "EmptyTableViewCell")
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableData.count == 0 { return 1 }
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableData.count == 0 { return 1 }
        return tableData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.tableData.count == 0 {
            let cell:EmptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell", for: indexPath) as! EmptyTableViewCell
            self.tableView.isScrollEnabled = false
            self.tableView.separatorStyle = .none
            cell.render(for: "No exercize history found! ")
            return cell
        }
        
        self.tableView.isScrollEnabled = true
        let cell:MainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        let set:Set = tableData[indexPath.section][indexPath.row]
        cell.render(for: "\(set.reputition)x \(set.weight)kg" )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableData.count == 0 { return 0.1 }
        return 36
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableData.count == 0 { return nil }
        let string:String = exercizeNames[section]
        return self.setupHeader(with: string, height:36)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit:UITableViewRowAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let set:Set = self.tableData[indexPath.section][indexPath.row]
            self.showEditModal(set: set)
        }
        
        let delete:UITableViewRowAction = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let set:Set = self.tableData[indexPath.section][indexPath.row]
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
    
    
}

