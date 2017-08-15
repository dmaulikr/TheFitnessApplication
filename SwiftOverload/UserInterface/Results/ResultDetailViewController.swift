//
//  ResultDetailViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 21-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class ResultDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    
    @IBOutlet weak var graph: Graph!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    
    var exercize:Exercize!
    var sets:[Set] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllSets()
        setupGraph()
        setupTableView()
        setupNavigation()
    }
    
    func setupNavigation() {
        self.title = "Exercize progress"
        let backButton:NavigationButton = NavigationButton(image: "back_icon", position: .left)
        backButton.addTarget(self, action: #selector(self.goToPreviousController), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func setupGraph() {
        
        let components = getCalendarComponents()
        let month = components.month!
        var previousMonth = components.month! - 1
        var year = components.year!
        
        var dateString:String = "\(year)-\(month)"
        if month < 10 { dateString = "\(year)-0\(month)" }
        
        if previousMonth == -1 {
            previousMonth = 12
            year = year - 1
        }
        
        var prevDateString:String = "\(year)-\(previousMonth)"
        if previousMonth < 10 { prevDateString = "\(year)-0\(previousMonth)" }
        
        var weightArray:[Int] = []
        var repArray:[Int] = []
        
        for set in sets {
            if set.date.contains(dateString) {
                weightArray.append(set.weight)
                repArray.append(set.reputition)
            }
            else if set.date.contains(prevDateString) {
                repArray.append(set.reputition)
            }
        }
        
        if weightArray.count != 0 {
            graph.weightPoints = weightArray
            graph.repPoints = repArray
        }
    }
    
    func getCalendarComponents() -> DateComponents {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day, .month, .year], from: Date())
        return components
    }
    
    func getBestSet() -> Set? {
        var bestSet:Set?
        for set in sets {
            if bestSet != nil {
                let bestPoints:Float = Float(bestSet!.weight * bestSet!.reputition)
                let newPoints:Float = Float(set.weight * set.reputition)
                if newPoints > bestPoints { bestSet = set }
            } else {
                bestSet = set
            }
        }
        
        return bestSet
    }
    
    func getLastSet() -> Set? {
        if sets.count > 0 { return sets[0] }
        return nil
    }
    
    func getAvgWeight() -> Float {
        var totalWeight:Float = 0
        var totalSets:Float = 0
        
        for set in sets {
            totalSets += 1
            totalWeight += Float(set.weight)
        }
        
        if totalWeight == 0 { return 0 }
        return Float( totalWeight / totalSets )
    }
    
    func get1RM() -> Float {
        
        var firstSet:Set?
        for set in sets {
            if set.reputition < 13 {
                firstSet = set
                break
            }
        }
        
        var oneRepMax:Float = 0
        
        if firstSet != nil {
            let set = firstSet!
            if set.reputition == 1 { oneRepMax = Float(set.weight) }
            if set.reputition == 2 { oneRepMax = Float(set.weight) / 95 * 100 }
            if set.reputition == 3 { oneRepMax = Float(set.weight) / 93 * 100 }
            if set.reputition == 4 { oneRepMax = Float(set.weight) / 90 * 100 }
            if set.reputition == 5 { oneRepMax = Float(set.weight) / 87 * 100 }
            if set.reputition == 6 { oneRepMax = Float(set.weight) / 85 * 100 }
            if set.reputition == 7 { oneRepMax = Float(set.weight) / 83 * 100 }
            if set.reputition == 8 { oneRepMax = Float(set.weight) / 80 * 100 }
            if set.reputition == 9 { oneRepMax = Float(set.weight) / 77 * 100 }
            if set.reputition == 10 { oneRepMax = Float(set.weight) / 75 * 100 }
            if set.reputition == 11 { oneRepMax = Float(set.weight) / 73 * 100 }
            if set.reputition == 12 { oneRepMax = Float(set.weight) / 70 * 100 }
        }
        
        return oneRepMax
    }
    
    func getTotalPoints() -> Float {
        var totalPoints:Float = 0
        for set in sets {
            let setPoints = Float(set.weight * set.reputition)
            totalPoints += setPoints
        }
        return totalPoints
    }
    
    func getSetCount() -> Int {
        return sets.count
    }
    
    func getAllSets() {
        sets = SetHelper.sharedInstance.getAllSets(for: exercize.id)
    }
    
    func loadAllSets() {
        let vc:DetailTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "allSets") as! DetailTableViewController
        vc.exercize = self.exercize
        self.navigationController?.pushViewController(vc, animated: true)
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
        self.tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        
        let refresher:UIRefreshControl = createRefresher()
        self.tableView.addSubview(refresher)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 4 }
        else if section == 1 { return 2 }
        else if section == 2 { return 1 }
        else { return 0 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                if let set:Set = getBestSet() {
                    cell.render(for: "Best set", sub: "\(set.reputition)x \(set.weight)kg")
                } else {
                    cell.render(for: "Best set", sub:"No history found!")
                }
                
            }
            else if indexPath.row == 1 {
                if let set:Set = getLastSet() {
                    cell.render(for: "Last set", sub: "\(set.reputition)x \(set.weight)kg")
                } else {
                    cell.render(for: "Last set", sub:"No history found!")
                }
            }
            else if indexPath.row == 2 {
                let averageWeight:String = String(format: "%.0f kg", ceilf(getAvgWeight()))
                cell.render(for: "Average weight", sub: averageWeight)
            }
            else if indexPath.row == 3 {
                let oneRepMax:Float = self.get1RM()
                let stringValue:String = String(format: "%.0f kg", ceilf(oneRepMax))
                cell.render(for: "One Rep Max", sub: stringValue)
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let count:Int = getSetCount()
                cell.render(for: "Total sets", sub: "\(count) sets")
            }
            else if indexPath.row == 1 {
                let totalPoints:String = String(format: "%.0f points", getTotalPoints())
                cell.render(for: "Total points earned", sub: totalPoints)
            }
        }
        
        if indexPath.section == 2 {
            cell.render(for: "Show all sets")
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.loadAllSets))
            cell.addGestureRecognizer(tap)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 { return 30 }
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return self.setupHeader(with: "Information", height: 45) }
        else { return self.setupHeader(with: " ", height: 45) }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}
