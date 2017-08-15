//
//  ExercisesCollectionViewController.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 03-07-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

class ExercisesTableViewController: UITableViewController, UITextFieldDelegate, UISearchBarDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    var modalView:Modal?
    
    // MARK: - Variables
    
    var muscle:Muscle!
    var selectedExercize:Exercize?
    
    var groups:[Group] = []
    var allExercises:[ [Exercize] ] = []
    var disabledExercises:[Exercize] = []
    
    var showSearch:Bool = false
    var isEditMode:Bool = false
    var isLoading:Bool = false
    
    // MARK: - General
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigation()
        setupSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showLoader()
        isLoading = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserDefaults()
        reloadTableView()
    }
    
    // MARK: - Navigation
    
    func setupNavigation() {
        self.title = "\(muscle.name) exercises"
        let backButton:NavigationButton = NavigationButton(image: "back_icon", position: .left)
        backButton.addTarget(self, action: #selector(self.goToPreviousController), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let buttonImage:UIImage = UIImage(named: "icon_eye_white")!
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(self.editButtonClicked(_:)))
    }
    
    @objc func editButtonClicked(_ sender: Any) {
        isEditMode = true
        self.searchBar.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveButtonClicked))
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
    
    // MARK: Modals
    
    func showEditModal(exercize: Exercize) {
        selectedExercize = exercize
        
        modalView = Modal(with: "Within this modal you can modify the name of your exercize", textfield: exercize.name, button: "SAVE IT")
        modalView?.buttonComponent.removeTarget(nil, action: nil, for: .allEvents)
        modalView?.buttonComponent.addTarget(self, action: #selector(self.update), for: .touchUpInside)
        modalView?.textfieldComponent!.delegate = self
        self.view.window?.addSubview(modalView!)
    }
    
    func showDeleteModal(exercize: Exercize) {
        selectedExercize = exercize
        
        modalView = Modal(warning: "Are you really really sure that you really want to delete \(exercize.name)", button: "DELETE IT")
        modalView?.buttonComponent.removeTarget(nil, action: nil, for: .allEvents)
        modalView?.buttonComponent.addTarget(self, action: #selector(self.remove), for: .touchUpInside)
        self.view.window?.addSubview(modalView!)
    }
    
    // MARK: Actions
    
    @objc func insert() {
        let group = self.groups[(modalView!.textfieldComponent?.tag)!].id
        if let name = modalView!.textfieldComponent?.text {
            if name.characters.count > 0 {
                ExercizeHelper.sharedInstance.create(exercize: name, group: group, completionHandler: { (finished) in
                    if finished {
                        self.reloadTableView()
                        modalView!.hideModal()
                    }
                })
            }
        }
    }
    
    @objc func update() {
        if let name = modalView!.textfieldComponent?.text {
            ExercizeHelper.sharedInstance.update(exercize: selectedExercize!, to: name, completionHandler: { (succes, error) in
                self.reloadTableView()
                modalView!.hideModal()
            })
        }
    }
    
    @objc func remove() {
        var points:Int = 0
        let sets:[Set] = SetHelper.sharedInstance.getAllSets(for: selectedExercize!.id)
        
        for set in sets {
            SetHelper.sharedInstance.destroy(set: set, completionHandler: { (success, error) in
                points += (set.weight * set.reputition)
            })
        }
        
        ExercizeHelper.sharedInstance.delete(exercize: selectedExercize!, completionHandler: { (succes, error) in
            self.reloadTableView()
            modalView!.removeFromSuperview()
            PlayerHelper.sharedInstance.addToHighscore(points: points * -1, completionHandler: { (highscore) in
                let defaults:UserDefaults = UserDefaults.standard
                if defaults.bool(forKey: "ShowPointsModal") == true {
                    modalView = Modal(with: "You lost \(points) points. Your total score is updated to \(highscore) points!", button: "OKAY!")
                    self.view.window?.addSubview(modalView!)
                }
            })
        })
    }
    
    // MARK: - UserDefaults
    
    func getUserDefaults() {
        disabledExercises.removeAll()
        disabledExercises = Utils.getDefaults(for: "DisabledExercises") as! [Exercize]
    }
    
    func setUserDefaults() {
        var archivedData:[Data] = []
        for exercize in disabledExercises {
            let data = NSKeyedArchiver.archivedData(withRootObject: exercize)
            archivedData.append(data)
        }
        Utils.setDefaults(archivedData, for:"DisabledExercises")
    }
        
    // MARK: - Edit
    
    func disableCellForIndexPath(_ indexPath:IndexPath) {
        if indexPath.section > 0 {
            let exercize:Exercize = allExercises[indexPath.section - 1][indexPath.row]
            if let index = disabledExercises.index(where: { $0.id == exercize.id } ) {
                disabledExercises.remove(at: index)
            }
            else {
                disabledExercises.append(exercize)
            }
            self.reloadTableView()
        }
    }
    
    // MARK: Helpers
    
    func filterExercises(for text:String) {
        
        self.loadTableData()
        
        var filteredExercises:[ [Exercize] ] = []
        for exercizeArray in allExercises {
            var exercises:[Exercize] = []
            exercises = exercizeArray.filter({ $0.name.lowercased().contains(text.lowercased()) == true })
            filteredExercises.append(exercises)
        }
        allExercises = filteredExercises
        self.tableView.reloadData()
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Table view
    
    func setupTableView() {
//        self.tableView.isEditing = true
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
        self.tableView.reloadData()
    }
    
    func reloadTableView() {
        self.loadTableData()
        if !isEditMode {
            updateTableView()
        }
        
        isLoading = false
        self.tableView.reloadData()
        self.hideLoader()
    }
    
    func updateTableView() {
        for exercize in self.disabledExercises {
            for i in 0..<allExercises.count {
                if let index = allExercises[i].index(where: { $0.id == exercize.id }) {
                    removeItem(at: index, in: i)
                }
            }
        }
    }
    
    func removeItem(at index:Int, in array:Int) {
        allExercises[array].remove(at: index)
    }
    
    func tableViewIsEmpty() -> Bool {
        for exercizeArray in allExercises {
            if exercizeArray.count > 0 { return false }
        }
        return true
    }
    
    func renderEdit(_ cell: MainTableViewCell, for indexPath:IndexPath) -> MainTableViewCell {
        cell.setEditingView()
        
        for exercize in disabledExercises {
            let curExercize:Exercize = allExercises[indexPath.section - 1][indexPath.row]
            if curExercize.id == exercize.id {
                cell.setEditingView(.disabled)
            }
        }
        return cell
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
    
    // MARK: Section header button
    
    @objc func addExercizeButtonClicked(_ sender: UIButton) {
        modalView = Modal(with: "Whitin this modal you can add a new exercize", textfield: "", button: "ADD IT")
        modalView?.textfieldComponent?.delegate = self
        modalView?.textfieldComponent?.placeholder = "Exercize name"
        modalView?.textfieldComponent?.tag = sender.tag
        modalView?.buttonComponent.removeTarget(nil, action: nil, for: .allEvents)
        modalView?.buttonComponent.addTarget(self, action: #selector(self.insert), for: .touchUpInside)
        self.view.window?.addSubview(modalView!)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isEditMode { return groups.count + 1}
        if groups.count == 0 { return 1 }
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isEditMode {
            if section == 0 { return 1 }
            else { return allExercises[section - 1].count }
        } else {
            if groups.count == 0 && isLoading == false { return 1 }
            if groups.count == 0 && isLoading == true { return 0 }
            if tableViewIsEmpty() && section == allExercises.count - 1 { return 1 }
            return allExercises[section].count
        }        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.isScrollEnabled = true
        self.tableView.separatorStyle = .singleLine
        
        // Empty
        if tableViewIsEmpty() { 
            return self.renderEmptyCell(for: indexPath)
        }
        
        // Edit info 
        if isEditMode && indexPath.section == 0 {
            return self.renderDetailCell(for: indexPath)
        }
        
        // Exercize cell
        var cell:MainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        
        // Edit
        if(isEditMode) {
            let exercize = allExercises[indexPath.section - 1][indexPath.row]
            cell.render(for: exercize.name)
            cell = self.renderEdit(cell, for: indexPath)
            return cell
        }
        // Info cell
        else {
            let exercize = allExercises[indexPath.section][indexPath.row]
            var resultString = ""
            if exercize.last != nil { resultString = "\(exercize.last!.reputition)x \(exercize.last!.weight)kg" }
            cell.render(for: exercize.name, sub: resultString)
            cell.cellSubLabel.textColor = UIColor.customDarkGray
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isEditMode && indexPath.section == 0 { return 75 }
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isEditMode {
            if section == 0 { return 1 }
            if allExercises[section - 1].count == 0 { return 1 }
            
        } else {
            if groups.count == 0 { return 1 }
            if allExercises[section].count == 0 { return 1 }
        }
        
        return 45
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if isEditMode {
            if section == 0 { return nil }
            if allExercises[section - 1].count == 0 { return nil }
            
            let group:Group = groups[section - 1]
            let header:UIView = self.setupHeader(with: group.name, height: 45)
            return header
        }
        
        if groups.count == 0 { return nil }
        if allExercises[section].count == 0 { return nil }
        
        let group:Group = groups[section]
        let header:UIView = self.setupHeader(with: group.name, height: 45)
        let addBtn:UIButton = self.setupHeaderButton(for: header, with: "Add")
        addBtn.tag = section
        addBtn.addTarget(self, action: #selector(addExercizeButtonClicked(_:)), for: .touchUpInside)
        header.addSubview(addBtn)
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableViewIsEmpty() {
            if isEditMode == false {
                let exercize:Exercize = allExercises[indexPath.section][indexPath.row]
                self.performSegue(withIdentifier: "Exercize", sender: exercize)
            }
            else {
                disableCellForIndexPath(indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isEditMode { return false }
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit:UITableViewRowAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            let exercize:Exercize = self.allExercises[indexPath.section][indexPath.row]
            self.showEditModal(exercize: exercize)
        }
        let delete:UITableViewRowAction = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            let exercize:Exercize = self.allExercises[indexPath.section][indexPath.row]
            self.showDeleteModal(exercize: exercize)
        }
        
        edit.backgroundColor = UIColor.darkGray
        delete.backgroundColor = UIColor.customRed
        return [edit, delete]
    }
    
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        //
//    }
    
    // MARK: Scrollview
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.hideKeyboard()
        if showSearch == false && self.searchBar.text == "" {
            if scrollView.contentOffset.y < 40 {
                scrollView.setContentOffset( CGPoint.init(x: 0, y: 40) , animated: false)
            }
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 45 { showSearch = true }
        else { showSearch = false }
    }
    
    // MARK: Searchbar
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" { self.reloadTableView() }
        else { self.filterExercises(for: searchBar.text!) }
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" { self.reloadTableView() }
    }
    
    // MARK: Textfields
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.modalView!.frame = CGRect(
                x: self.modalView!.frame.origin.x,
                y: self.modalView!.frame.origin.y - 100,
                width: self.modalView!.frame.size.width,
                height: self.modalView!.frame.size.height
            )
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.modalView!.frame = CGRect(
                x: self.modalView!.frame.origin.x,
                y: self.modalView!.frame.origin.y + 100,
                width: self.modalView!.frame.size.width,
                height: self.modalView!.frame.size.height
            )
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" { return false }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Exercize" {
            let vc:DetailTableViewController = segue.destination as! DetailTableViewController
            vc.exercize = sender as! Exercize
        }
    }
    
}

