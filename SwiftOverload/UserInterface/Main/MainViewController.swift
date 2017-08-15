//
//  MainViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 12-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var headerView: ExperienceHeaderView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Variables
    
    var types:[String] = []
    var allMuscles:[ [Muscle] ] = []
    var disabledMuscles:[Muscle] = []
    
    var showSearch:Bool = false
    var isEditMode:Bool = false
    var isLoading:Bool = false
    
    // MARK: - General
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigation()
        self.setupTableView()
        self.setupSearch()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        showLoader()
        isLoading = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setHeaderValues()
        getUserDefaults()
        reloadTableView()
    }
    
    // MARK: Navigation
    
    func setupNavigation() {
        self.title = "Training"
        
        let editImage:UIImage = UIImage(named: "icon_eye_white")!
        let editButton:UIBarButtonItem = UIBarButtonItem(image: editImage, style: .plain, target: self, action: #selector(self.editButtonClicked(_:)))
        self.navigationItem.setRightBarButton(editButton, animated: true)
    }
    
    // MARK: Selectors
    
    @objc func showProgressView(_ sender: Any) {
       self.performSegue(withIdentifier: "results", sender: nil)
    }
    
    @objc func showSettingsView(_ sender: Any) {
        self.performSegue(withIdentifier: "settings", sender: nil)
    }
    
    @objc func editButtonClicked(_ sender: Any) {
        isEditMode = true
        self.searchBar.isHidden = true
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveButtonClicked))
        self.navigationItem.setRightBarButtonItems([saveButton], animated: true)
        self.reloadTableView()
    }
    
    @objc func saveButtonClicked(_ sender: Any) {
        isEditMode = false
        self.searchBar.isHidden = false
        setupNavigation()
        self.setUserDefaults()
        self.reloadTableView()
    }
    
    // MARK: Content
    
    func setupSearch() {
        self.searchBar.delegate = self
        self.searchBar.barStyle = .default
        self.searchBar.barTintColor = UIColor.white
        self.searchBar.searchBarStyle = .minimal
    }
    
    func setHeaderValues() {
        DatabaseHelper.sharedInstance.openDatabase()
        let player:Player = PlayerHelper.sharedInstance.getPlayer()
        headerView.experienceLabel.text = "\(player.experience)"
        DatabaseHelper.sharedInstance.closeDatabase()
    }
    
    // MARK: - UserDefaults
    
    func getUserDefaults() {
        disabledMuscles.removeAll()
        disabledMuscles = Utils.getDefaults(for: "DisabledMuscles") as! [Muscle]
    }
    
    func setUserDefaults() {
        var archivedData:[Data] = []
        for muscle in disabledMuscles {
            let data = NSKeyedArchiver.archivedData(withRootObject: muscle)
            archivedData.append(data)
        }
        Utils.setDefaults(archivedData, for:"DisabledMuscles")
    }
    
    // MARK: - Edit view
    
    func disableCellForIndexPath(_ indexPath:IndexPath) {
        if indexPath.section > 0 {
            let muscle:Muscle = allMuscles[indexPath.section - 1][indexPath.row]
            if let index = disabledMuscles.index(where: { $0.name == muscle.name}) { disabledMuscles.remove(at: index) }
            else { disabledMuscles.append(muscle) }
            self.reloadTableView()
        }
    }
    
    // MARK: Helpers
    
    func filterMuscles(for text:String) {
        
        self.loadTableData()
        
        var filteredMuscles:[ [Muscle] ] = []
        for muscleArray in allMuscles {
            var muscles:[Muscle] = []
            muscles = muscleArray.filter({ $0.name.lowercased().contains(text.lowercased()) == true })
            filteredMuscles.append(muscles)
        }
        allMuscles = filteredMuscles
        self.tableView.reloadData()
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
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
        
    }
    
    func reloadTableView() {
        loadTableData()
        if !isEditMode {
            updateTableView()
        }
        
        isLoading = false
        self.tableView.reloadData()
        self.hideLoader()
    }
    
    func updateTableView() {
        for muscle in self.disabledMuscles {
            for i in 0..<allMuscles.count {
                if let index = allMuscles[i].index(where: { $0.name == muscle.name }) {
                    removeItem(at: index, in: i)
                }
            }
        }
    }
    
    func removeItem(at index:Int, in array:Int) {
        allMuscles[array].remove(at: index)
    }
    
    func tableViewIsEmpty() -> Bool {
        for muscleArray in allMuscles {
            if muscleArray.count > 0 {
                return false
            }
        }
        return true
    }
    
    func renderEdit(_ cell: MainTableViewCell, for indexPath:IndexPath) -> MainTableViewCell {
        cell.setEditingView()
        for muscle in disabledMuscles {
            if cell.cellLabel.text! == muscle.name {
                cell.setEditingView(.disabled)
            }
        }
        return cell
    }
    
    func renderEmptyCell(for indexPath:IndexPath) -> EmptyTableViewCell {
        let cell:EmptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EmptyTableViewCell", for: indexPath) as! EmptyTableViewCell
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
        cell.render(for: "No muscles found!")
        return cell
    }
    
    func renderDetailCell(for indexPath:IndexPath) -> DetailTableViewCell {
        let cell:DetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DetailTableViewCell", for: indexPath) as! DetailTableViewCell
        cell.render(for: "Enable/disable visibility of muscles by tapping the muscle names below!")
        return cell
    }
    
    func renderMainCell(for indexPath:IndexPath) -> MainTableViewCell {
        var cell:MainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        
        if isEditMode {
            let muscle:Muscle = allMuscles[indexPath.section - 1][indexPath.row]
            cell.render(for: muscle.name)
            cell = self.renderEdit(cell, for: indexPath)
        }
        else {
            let muscle:Muscle = allMuscles[indexPath.section][indexPath.row]
            cell.render(for: muscle.name)
        }
        
        return cell
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isEditMode { return types.count + 1}
        if types.count == 0 { return 1 }
        return types.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading { return 0 }
        if tableViewIsEmpty() && section == allMuscles.count - 1 { return 1 }
        
        if isEditMode {
            if section == 0 { return 1 }
            return allMuscles[section - 1].count
        }
        else {
            return allMuscles[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.isScrollEnabled = true
        self.tableView.separatorStyle = .singleLine
        
        if tableViewIsEmpty() { return self.renderEmptyCell(for: indexPath) }
        if isEditMode && indexPath.section == 0 { return self.renderDetailCell(for: indexPath) }
        return renderMainCell(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEditMode && indexPath.section == 0 { return 75 }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isLoading { return 1}
        if isEditMode {
            if section == 0 { return 0.1 }
            if allMuscles[section - 1].count == 0 { return 0.1 }
        }
        else {
            if allMuscles[section].count == 0 { return 0.1 }
        }
        
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerTitle:String = ""
        
        if isLoading { return nil }
        
        if isEditMode {
            if section == 0 { return nil }
            if allMuscles[section - 1].count == 0 { return nil }
            headerTitle = types[section - 1]
        }
        else {
            if allMuscles[section].count == 0 { return nil }
            headerTitle = types[section]
        }
        
        return self.setupHeader(with: headerTitle, height:45)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableViewIsEmpty() { return }
        
        if isEditMode {
            if indexPath.section > 0 {
                disableCellForIndexPath(indexPath)
            }
        }
        else {
            let muscle:Muscle = allMuscles[indexPath.section][indexPath.row]
            self.performSegue(withIdentifier: "Exercises", sender: muscle)
        }
    }
    
    // MARK: Scrollview
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.hideKeyboard()
        
        if showSearch == false {
            if scrollView.contentOffset.y < 40 {
                scrollView.setContentOffset( CGPoint.init(x: 0, y: 40) , animated: false)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 45 { showSearch = true }
        else { showSearch = false }
    }
    
    // MARK: Searchbar
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" { self.reloadTableView() }
        else { self.filterMuscles(for: searchBar.text!) }
        
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" { self.reloadTableView() }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Exercises" {
            let viewController:ExercisesTableViewController = segue.destination as! ExercisesTableViewController
            viewController.muscle = sender as! Muscle
        }
    }
    
}

