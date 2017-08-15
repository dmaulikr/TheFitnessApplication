//
//  ResultExercisesViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 20-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class ResultExercisesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    // MARK: Outlets
    
    @IBOutlet weak var headerView: ExperienceHeaderView!
    @IBOutlet weak var tableView: UITableView!
    
    var segmentedController: UISegmentedControl!
    
    var modalView:Modal?
    
    // MARK: - Variables
    
    var muscle:Muscle!
    var selectedExercize:Exercize?
    
    var groups:[Group] = []
    var allExercises:[ [Exercize] ] = []
    var allPoints:[ [Float] ] = []
    
    var isLoading:Bool = false
    
    // MARK: - General
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigation()
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
    
    // MARK: - Navigation
    
    func setupNavigation() {
        self.title = "\(muscle .name) progress"
        let backButton:NavigationButton = NavigationButton(image: "back_icon", position: .left)
        backButton.addTarget(self, action: #selector(self.goToPreviousController), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func setHeaderValues() {
        DatabaseHelper.sharedInstance.openDatabase()
        let player:Player = PlayerHelper.sharedInstance.getPlayer()
        headerView.experienceLabel.text = "\(player.experience)"
        headerView.experienceLabel.text = ""
        
        segmentedController = UISegmentedControl()
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
    
    func getCurrentScore(for exercize:Int) -> Float {
        let comp = getCalendarComponents()
        let month:Int = comp.month!
        
        var dateString:String = "\(comp.year!)-\(month)"
        if month < 10 { dateString = "\(comp.year!)-0\(month)" }
        return getProgress(for: exercize, date: dateString)
    }
    
    func getLastMonthScore(for exercize:Int) -> Float {
        let comp = getCalendarComponents()
        let month:Int = comp.month! - 1
        
        var dateString:String = "\(comp.year!)-\(month)"
        if month < 10 { dateString = "\(comp.year!)-0\(month)" }
        return getProgress(for: exercize, date: dateString)
    }
    
    func getLastYearScore(for exercize:Int) -> Float {
        let comp = getCalendarComponents()
        let year:Int = comp.year! - 1
        let dateString:String = "\(year)"
        return getProgress(for: exercize, date: dateString)
    }
    
    func getCalendarComponents() -> DateComponents {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day, .month, .year], from: Date())
        return components
    }
    
    func getProgress(for exercize:Int, date:String) -> Float {
        
        let points:Float = self.getAveragePoints(for: exercize, date: date)
        
//        if points == 0 {
//            points = self.getFirstPoints(for: exercize)
//        }
            
        return points
    }
    
    func getAveragePoints(for exercize:Int, date:String) -> Float {
        var totalWeight:Float = 0
        var totalReps:Float = 0
        var totalSets:Float = 0
        
        let query:String =  "SELECT count(weight) as count, SUM(weight) as weight, SUM(reputition) as reputition from sets " +
            "WHERE exercize_id = \(exercize) " +
        "AND date LIKE '%\(date)%' "
        
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
    
    func getFirstPoints(for exercize:Int) -> Float {
        var totalWeight:Float = 0
        var totalReps:Float = 0
        var totalSets:Float = 0
        
        var idArray:String = ""
        let idquery:String = "SELECT min(sets.id) as id from sets WHERE exercize_id = \(exercize)"
        
        if let idSet:FMResultSet = DatabaseHelper.sharedInstance.execute(query: idquery) {
            while idSet.next() {
                let id = Int(idSet.int(forColumn: "id"))
                if idArray == "" { idArray = "(\(id)" }
                else { idArray = idArray + ",\(id)" }
            }
        }
        idArray = idArray + ")"
        
        let query:String = "SELECT weight, reputition FROM sets " +
            "WHERE exercize_id = \(exercize) " +
        "AND id in \(idArray)"
        
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
    
    // MARK: - Table view
    
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
    
    func loadTableData() {
        allExercises = []
        groups = GroupHelper.sharedInstance.getAllGroups(for: muscle.id)
        
        for group in groups {
            let exercises:[Exercize] = ExercizeHelper.sharedInstance.getAllExercises(for: group.id)
            allExercises.append(exercises)
        }
        
        DatabaseHelper.sharedInstance.openDatabase()
        
        for exercizeArray in allExercises {
            var pointArray:[Float] = []
            exercizeArray.forEach({ exercize in
                var newAvg:Float = Float( self.getCurrentScore(for: exercize.id) )
                let oldAvg:Float = Float( self.getLastMonthScore(for: exercize.id) )
                var progress:Float = 0
                
                if newAvg == 0 { newAvg = oldAvg }
                
                if oldAvg > 0 {
                    progress = Float(( (newAvg - oldAvg) / oldAvg) * 100)
                }
                pointArray.append(progress)
                
            })
            allPoints.append(pointArray)
        }
        
        DatabaseHelper.sharedInstance.closeDatabase()
        
        self.tableView.reloadData()
    }
    
    func reloadTableView() {
        self.loadTableData()
        
        isLoading = false
        self.tableView.reloadData()
        self.hideLoader()
    }
    
    func tableViewIsEmpty() -> Bool {
        for exercizeArray in allExercises {
            if exercizeArray.count > 0 { return false }
        }
        return true
    }
    
    func renderEmptyCell(for indexPath:IndexPath) -> EmptyTableViewCell {
        let cell:EmptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell", for: indexPath) as! EmptyTableViewCell
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
        cell.render(for: "No exercises found!")
        return cell
    }
    
    func renderDetailCell(for indexPath:IndexPath) -> DetailTableViewCell {
        let cell:DetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as! DetailTableViewCell
        cell.render(for: "Enable/disable visibility of exercises by tapping the exercize names below!")
        return cell
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if groups.count == 0 { return 1 }
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groups.count == 0 && isLoading == false { return 1 }
        if groups.count == 0 && isLoading == true { return 0 }
        if tableViewIsEmpty() && section == allExercises.count - 1 { return 1 }
        return allExercises[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.isScrollEnabled = true
        self.tableView.separatorStyle = .singleLine
        
        // Empty
        if tableViewIsEmpty() {
            return self.renderEmptyCell(for: indexPath)
        }
        
        // Exercize cell
        let cell:MainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        
        let exercize = allExercises[indexPath.section][indexPath.row]
        let points:Float = allPoints[indexPath.section][indexPath.row]
        
        var pointString:String = String.init(format: "%.0f %%%", points)
        if points >= 0 { pointString = "+" + pointString }
        
        cell.render(for: exercize.name, sub: pointString)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if groups.count == 0 { return 1 }
        if allExercises[section].count == 0 { return 1 }
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if groups.count == 0 { return nil }
        if allExercises[section].count == 0 { return nil }
        
        let group:Group = groups[section]
        let header:UIView = self.setupHeader(with: group.name, height: 45)
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exercize:Exercize = allExercises[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "Exercize", sender: exercize)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Exercize" {
            let vc:ResultDetailViewController = segue.destination as! ResultDetailViewController
            vc.exercize = sender as! Exercize
        }
    }
    
}



