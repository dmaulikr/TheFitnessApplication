//
//  ResultMainViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 19-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class ResultMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var headerView: ExperienceHeaderView!
    @IBOutlet weak var tableView: UITableView!
    
    var segmentedController: UISegmentedControl!
    
    // MARK: Variables
    
    var types:[String] = []
    var allMuscles:[ [Muscle] ] = []
    var allPoints:[ [Float] ] = []
    var isLoading:Bool = false
    
    // MARK: - General
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigation()
        self.setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setHeaderValues()
        showLoader()
        isLoading = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadTableView()
    }
    
    // MARK: Navigation
    
    func setupNavigation() {
        self.title = "Progress"
    }
    
    // MARK: Selectors
    
    @objc func showMainView() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: Content
    
    func setHeaderValues() {
        DatabaseHelper.sharedInstance.openDatabase()
        let player:Player = PlayerHelper.sharedInstance.getPlayer()
        headerView.experienceLabel.text = "\(player.experience)"
        headerView.experienceLabel.text = ""
        
        segmentedController = UISegmentedControl()
        // segmentedController.insertSegment(withTitle: "last year", at: 1, animated: true)
        segmentedController.insertSegment(withTitle: "Progress since last month", at: 0, animated: false)
        segmentedController.frame = CGRect(x: 0, y: 0, width: headerView.frame.size.width - 50, height: 50)
        segmentedController.center = headerView.center
        segmentedController.tintColor = .white
        segmentedController.backgroundColor = .customDarkGray
        segmentedController.selectedSegmentIndex = 0
        segmentedController.addTarget(self, action: #selector(self.segmentControlChanged(_:)), for: .valueChanged)
        headerView.addSubview(segmentedController)
        
        DatabaseHelper.sharedInstance.closeDatabase()
    }
    
    // MARK: Helpers
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: Progress
    
    func getCurrentScore(for muscle:Int) -> Float {
        let comp = getCalendarComponents()
        let month:Int = comp.month!
        
        var dateString:String = "\(comp.year!)-\(month)"
        if month < 10 { dateString = "\(comp.year!)-0\(month)" }
        return getProgress(for: muscle, date: dateString)
    }
    
    func getLastMonthScore(for muscle:Int) -> Float {
        let comp = getCalendarComponents()
        let month:Int = comp.month! - 1
        
        var dateString:String = "\(comp.year!)-\(month)"
        if month < 10 { dateString = "\(comp.year!)-0\(month)" }
        return getProgress(for: muscle, date: dateString)
    }
    
    func getLastYearScore(for muscle:Int) -> Float {
        let comp = getCalendarComponents()
        let year:Int = comp.year! - 1
        let dateString:String = "\(year)"
        return getProgress(for: muscle, date: dateString)
    }
    
    func getCalendarComponents() -> DateComponents {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day, .month, .year], from: Date())
        return components
    }
    
    func getProgress(for muscle:Int, date:String) -> Float {
        
        let points:Float = self.getAveragePoints(for: muscle, date: date)
        
//        if points == 0 {
//            points = self.getFirstPoints(for: muscle)
//        }
            
        return points
    }
    
    func getAveragePoints(for muscle:Int, date:String) -> Float {
        var totalWeight:Float = 0
        var totalReps:Float = 0
        var totalSets:Float = 0
        
        let query:String =  "SELECT COUNT(weight) as count, SUM(weight) as weight, SUM(reputition) as reputition from sets " +
            "JOIN exercises on exercize_id = exercises.id " +
            "JOIN groups on exercises.group_id = groups.id " +
            "JOIN muscles on groups.muscle_id = muscles.id " +
            "WHERE muscles.id = \(muscle) " +
            "AND sets.date LIKE '%\(date)%' " +
            "GROUP BY sets.exercize_id"
        
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: query) {
            while resultSet.next() {
                let count = Float(resultSet.int(forColumn: "count"))
                let avgWeight = Float(resultSet.int(forColumn: "weight"))
                let avgRep = Float(resultSet.int(forColumn: "reputition"))
                
                totalSets += 1
                if count > 0 {
                    totalWeight += avgWeight / count
                    totalReps += avgRep / count
                }
            }
        }
        
        if totalSets == 0 { return 0 }
        return (totalReps/totalSets) * (totalWeight/totalSets)
    }
    
    func getFirstPoints(for muscle:Int) -> Float {
        var totalWeight:Float = 0
        var totalReps:Float = 0
        var totalSets:Float = 0
        
        var idArray:String = ""
        let idquery:String = "SELECT min(sets.id) as id, exercises.name as name from sets JOIN exercises on exercize_id = exercises.id GROUP BY exercize_id "
        
        if let idSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: idquery) {
            while idSet.next() {
                let id = Int(idSet.int(forColumn: "id"))
                if idArray == "" { idArray = "(\(id)" }
                else { idArray = idArray + ",\(id)" }
            }
        }
        idArray = idArray + ")"
        
        let query:String = "SELECT weight as weight, reputition as reputition FROM sets " +
            "JOIN exercises on exercize_id = exercises.id " +
            "JOIN groups on exercises.group_id = groups.id " +
            "JOIN muscles on groups.muscle_id = muscles.id " +
            "WHERE muscles.id = \(muscle) " +
            "AND sets.id in \(idArray)"
        
        if let resultSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: query) {
            while resultSet.next() {
                let avgWeight = Float(resultSet.int(forColumn: "weight"))
                let avgRep = Float(resultSet.int(forColumn: "reputition"))
                
                totalWeight += avgWeight
                totalReps += avgRep
                totalSets += 1
            }
        }
        
        if totalSets == 0 { return 0 }
        return (totalReps / totalSets) * (totalWeight / totalSets)
    }
    
    // MARK: Segment control
    
    @objc func segmentControlChanged(_ segmentControl: UISegmentedControl) {
        self.reloadTableView()
    }
    
    // MARK: - Table View
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.customGray
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: false)
        
        self.tableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTableViewCell")
        self.tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "EmptyTableViewCell")
        self.tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailTableViewCell")
        
        let refresher:UIRefreshControl = self.createRefresher()
        self.tableView.addSubview(refresher)
    }
    
    func loadTableData() {
        types = []
        allMuscles = []
        allPoints = []
        
        let muscles:[Muscle] = MuscleHelper.sharedInstance.getAllMuscles()
        
        for muscle in muscles {
            if !types.contains(muscle.type) {
                types.append(muscle.type)
            }
        }
        
        for type in types {
            let typeArray = muscles.filter({ $0.type == type })
            allMuscles.append(typeArray)
        }
        
        DatabaseHelper.sharedInstance.openDatabase()
        
        for muscleArray in allMuscles {
            var pointArray:[Float] = []
            muscleArray.forEach({ muscle in
                
                var newAvg:Float = Float( self.getCurrentScore(for: muscle.id) )
                
                var oldAvg:Float = 0
                
                if segmentedController.selectedSegmentIndex == 0 {
                    oldAvg = Float( self.getLastMonthScore(for: muscle.id) )
                }
                else {
                    oldAvg = Float( self.getLastYearScore(for: muscle.id) )
                }
                
                if newAvg == 0 {
                    newAvg = oldAvg
                    
                }
                
                var progress:Float = 0
                if oldAvg > 0 {
                    progress = Float(( (newAvg - oldAvg) / oldAvg) * 100)
                }
                pointArray.append(progress)
                
            })
            allPoints.append(pointArray)
        }
        
        DatabaseHelper.sharedInstance.closeDatabase()
        
        isLoading = false
        self.tableView.reloadData()
        self.hideLoader()
    }
    
    func reloadTableView() {
        loadTableData()
    }
    
    func tableViewIsEmpty() -> Bool {
        for muscleArray in allMuscles {
            if muscleArray.count > 0 { return false }
        }
        return true
    }
    
    func renderEmptyCell(for indexPath:IndexPath) -> EmptyTableViewCell {
        let cell:EmptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell", for: indexPath) as! EmptyTableViewCell
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
        cell.render(for: "No muscles found!")
        return cell
    }
    
    func renderMainCell(for indexPath:IndexPath) -> MainTableViewCell {
        let cell:MainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        let muscle:Muscle = allMuscles[indexPath.section][indexPath.row]
        let points:Float = allPoints[indexPath.section][indexPath.row]
        
        var pointString:String = String(format: "+ %.0f %%%", points)
        if points < 0 { pointString = String(format: "- %.0f %%%", points * -1) }
        cell.render(for: muscle.name, sub:pointString )
        
        if points == 0 {
            cell.cellSubLabel.textColor = UIColor.customDarkGray
        }
        else if points > 0 {
            cell.cellSubLabel.textColor = UIColor.customGreen
        }
        else {
            cell.cellSubLabel.textColor = UIColor.customRed
        }
        
        return cell
    }
    
    func renderDetailCell(for indexPath:IndexPath) -> DetailTableViewCell {
        let cell:DetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as! DetailTableViewCell
        cell.render(for: "Progress since last month")
        return cell
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if types.count == 0 { return 1 }
        return types.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 0 }
        if tableViewIsEmpty() && section == allMuscles.count - 1 { return 1 }
        return allMuscles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.isScrollEnabled = true
        self.tableView.separatorStyle = .singleLine
        
        if tableViewIsEmpty() { return self.renderEmptyCell(for: indexPath) }
        return renderMainCell(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isLoading { return 0.1 }
        if allMuscles[section].count == 0 { return 0.1 }
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isLoading { return nil }
        if allMuscles[section].count == 0 { return nil }
        let headerTitle:String = types[section]
        return self.setupHeader(with: headerTitle, height:45)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableViewIsEmpty() { return }
        
        let muscle:Muscle = allMuscles[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "Exercises", sender: muscle)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Exercises" {
            let viewController:ResultExercisesViewController = segue.destination as! ResultExercisesViewController
            viewController.muscle = sender as! Muscle
        }
    }
    
    
}

