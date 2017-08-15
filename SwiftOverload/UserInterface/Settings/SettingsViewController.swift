//
//  SettingsViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 21-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: ExperienceHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
        self.setupNavigation()
        self.setupHeaderView()
    }
    
    // MARK: Navigation
    
    func setupNavigation() {
        self.title = "Settings"
    }
    
    // MARK: Header view
    func setupHeaderView() {
        let name = getUserName()
        headerView.experienceLabel.text = "Hi, \(name.capitalized)"
        headerView.pointsLabel.text = ""
    }
    
    // MARK: Helpers
    
    func getUserName() -> String {
        let defaults:UserDefaults = UserDefaults.standard
        let name = defaults.string(forKey: "userName")!
        return name
    }
    
    func getDateOfBirth() -> String {
        let defaults:UserDefaults = UserDefaults.standard
        let date = defaults.string(forKey: "userDateOfBirth")!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = formatter.date(from: date)
        
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: formattedDate!)
        
        return dateString
    }
    
    // MARK: Switches
    
    @objc func showPointsSwitchDidChanged(_ sender: UISwitch) {
        let state = sender.isOn
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(state, forKey: "ShowPointsModal")
        defaults.synchronize()
    }
    
    @objc func allowNotificationsSwitchDidChanged(_ sender: UISwitch) {
        let state = sender.isOn
        let defaults:UserDefaults = UserDefaults.standard
        defaults.set(state, forKey: "AllowNotifications")
        defaults.synchronize()
    }
    
    // MARK: Table view
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.customGray
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: false)
        self.tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        self.tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SwitchTableViewCell")
        self.tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
    }
    

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        else if section == 1 { return 2 }
        else if section == 2 { return 1 }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            let cell:MainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
            
            let name = self.getUserName()
            let dateOfbirth = self.getDateOfBirth()
            
            if indexPath.row == 0 { cell.render(for: "Username", sub: name) }
            if indexPath.row == 1 { cell.render(for: "Date of birth", sub: dateOfbirth) }
            if indexPath.row == 3 { cell.render(for: "Sex", sub: "Male") }
            return cell
            
        }
        
        else if indexPath.section == 1 {
            let cell:SwitchTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            
            let defaults:UserDefaults = UserDefaults.standard
            
            if indexPath.row == 0 {
                let state:Bool = defaults.bool(forKey: "ShowPointsModal")
                cell.render(for: "Show points pop-up", state: state)
                cell.cellSwitch.addTarget(self, action: #selector(self.showPointsSwitchDidChanged(_:)), for: UIControlEvents.valueChanged)
            }
            if indexPath.row == 1 {
                let state:Bool = defaults.bool(forKey: "AllowNotifications")
                cell.render(for: "Allow notifications", state: state)
                cell.cellSwitch.addTarget(self, action: #selector(self.allowNotificationsSwitchDidChanged(_:)), for: UIControlEvents.valueChanged)
            }
            return cell
        }
        
        let cell:DetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as! DetailTableViewCell
        cell.render(for: "Remove all data")
        cell.backgroundColor = UIColor.customRed
        cell.detailLabel.textAlignment = .center
        cell.detailLabel.textColor = UIColor.white
        cell.detailLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var string:String = ""
        if section == 0 { string = "Account" }
        if section == 1 { string = "Messages" }
        if section == 2 { string = " " }
        
        return self.setupHeader(with: string, height:36)
    }


}
