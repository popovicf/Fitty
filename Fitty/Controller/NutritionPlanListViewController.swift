//
//  NutritionPlanListViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase

class NutritionPlanListViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let loader = Loader()
    var hasTheFunctionCalled : Bool = false {
        didSet{
            hasTheFunctionCalled = true
        }
    }
    let service = FirebaseService()
    var trainersList = [User]()
    var nutritionPlanList = [[User: [[NutritionPlan]] ] ]()
    var uids = [String]()
    var selectedUser: User?
    var res = 0
    var numberOfSections: [Int] = []
    var selectedWeek = 0
    var selectedDay = 0
    var index = [IndexPath]()
    var dataCell = NutritionPlanListCell()
    let label = UILabel()
    let refreshControl = UIRefreshControl()
    let newView = UIView()
    let searchController = UISearchController()
    var filteredNutritionPlanList = [[User: [[NutritionPlan]] ] ]()
    var filteredTrainersList = [User]()
    var isFiltered = false
    var initialNutritionList = [[User: [[NutritionPlan]] ] ]()
    var indexPath = IndexPath()
    var isDayWeekFiltered = false
    var num = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 150
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.search
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        getData()
        addRefreshControl()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.numberOfSections(in: self.tableView) == 0 {
                DispatchQueue.main.async{
                    self.loader.endLoader()
                }
                self.view.addSubview(self.newView)
            } else {
                if let viewWithTag = self.view.viewWithTag(101) {
                    viewWithTag.removeFromSuperview()
                }
            }
        }
    }
    
    func getData(){
        if !hasTheFunctionCalled{
            loader.startLoader(vc: self)
        }
        hasTheFunctionCalled = true
        DispatchQueue.main.async {
            FollowService.followingTrainer { (user) in
                self.uids = user
                DispatchQueue.main.async {
                    self.getTrainers()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getTrainingData(){
        if !trainersList.isEmpty {
            nutritionPlanList.removeAll()
            numberOfSections.removeAll()
            for trainer in trainersList {
                self.service.getUserNutritionPlan(trainer_uid: trainer.uid) { (trainingPlan) in
                    self.nutritionPlanList.append([trainer: trainingPlan])
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } daysArray: { (daysArray) in } weeksArray: { (weeksArray) in } nutrition_uids: { (nutrition_uids) in }
            }
        }
    }
    
    func getTrainers(){
        Firestore.firestore().collection("users").getDocuments { (querySnap, error) in
            for uid in self.uids {
                guard let user = User(userID: uid, snapshot: querySnap) else {return}
                self.trainersList.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.getTrainingData()
                }
            }
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.beginRefreshing()
        DispatchQueue.main.async {
            FollowService.followingTrainer { (user) in
                self.uids = user
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.getTrainers()
        }
        self.refreshControl.endRefreshing()
    }
    
    func addRefreshControl(){
        let refreshImage = UIImageView()
        refreshImage.image = UIImage(named: "fittyLogo.png")
        refreshImage.contentMode = UIView.ContentMode.scaleAspectFit
        refreshImage.frame = refreshControl.bounds.offsetBy(dx: (self.view.frame.size.width / 2) - 30, dy: 0)
        refreshImage.frame.size.width = 80
        refreshImage.frame.size.height = 80
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.systemOrange
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching nutrition plans...", attributes: [.font : UIFont.systemFont(ofSize: 24), .foregroundColor : UIColor.systemOrange] )
        //refreshControl.addSubview(refreshImage)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
}
extension NutritionPlanListViewController: UITableViewDataSource, UITableViewDelegate, NutritionPlanListCellSelectionDelegate{
    func getFilteredData(list: [[User : [[NutritionPlan]]]]) {
        initialNutritionList = list
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var list = [[User: [[NutritionPlan]] ] ]()
        
        if !filteredNutritionPlanList.isEmpty {
            let set = Set(filteredNutritionPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                (trainingPlan1.keys.first!.full_name.localizedCaseInsensitiveCompare(trainingPlan2.keys.first!.full_name) == .orderedAscending)
            })
            for s in set {
                list.append(s)
            }
        } else if filteredNutritionPlanList.isEmpty && isFiltered == true {
            return 0
        } else {
            let set = Set(nutritionPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                (trainingPlan1.keys.first!.full_name.localizedCaseInsensitiveCompare(trainingPlan2.keys.first!.full_name) == .orderedAscending)
            })
            for s in set {
                list.append(s)
            }
        }
        
        var num = 0
        for l in list {
            if !l.values.contains([]) {
                num += 1
            }
        }
        numberOfSections.append(num)
        
        if num == 0 {
            newView.frame = self.view.bounds
            newView.tag = 101
            label.frame = newView.bounds
            label.text = "No nutrition plans"
            label.textColor = .systemOrange
            label.textAlignment = .center
            label.font.withSize(30)
            newView.addSubview(label)
            return 0
        }
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.nutritionPlanListCell, for: indexPath) as! NutritionPlanListCell
        dataCell = cell
        cell.delegate = self
        self.indexPath = indexPath
        
        if filteredNutritionPlanList.isEmpty {
            cell.filteredNutritionPlanList.removeAll()
            cell.uids = self.uids
            cell.trainersList = self.trainersList
            cell.nutritionPlanList = self.nutritionPlanList
            cell.num = indexPath.section
            
            DispatchQueue.main.async {
                cell.collectionView.reloadData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.loader.endLoader()
            })
            return cell
        } else {
            cell.uids = self.uids
            cell.trainersList = self.filteredTrainersList
            cell.filteredNutritionPlanList = self.filteredNutritionPlanList
            cell.section = indexPath.section
            
            DispatchQueue.main.async {
                cell.collectionView.reloadData()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        res = indexPath.section
        var list = [[User: [[NutritionPlan]] ] ]()
        list.removeAll()
        if filteredNutritionPlanList.isEmpty{
            let set = Set(nutritionPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                (trainingPlan1.keys.first!.full_name.localizedCaseInsensitiveCompare(trainingPlan2.keys.first!.full_name) == .orderedAscending)
            })
            for s in set where !s.values.contains([]){
                list.append(s)
            }
        } else {
            let set = Set(filteredNutritionPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                (trainingPlan1.keys.first!.full_name.localizedCaseInsensitiveCompare(trainingPlan2.keys.first!.full_name) == .orderedAscending)
            })
            for s in set where !s.values.contains([]){
                list.append(s)
            }
        }
        selectedUser = list[res].keys.first
        performSegue(withIdentifier: Constants.SegueTo.nutritionPlanListToShowPlan, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueTo.nutritionPlanListToShowPlan {
            let destionation = segue.destination as! ShowNutritionPlanViewController
            destionation.user = selectedUser!
        }
    }
}
extension NutritionPlanListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredNutritionPlanList.removeAll()
        filteredTrainersList.removeAll()
        
        if text.isEmpty || text == "" {
            isFiltered = false
            isDayWeekFiltered = false
        } else {
            nutritionPlanList.forEach { plan in
                plan.keys.forEach{ key in
                    plan.values.forEach{ value in
                        var sliceFinal = [[NutritionPlan]] ()
                        value.forEach { val in
                            var slice = [NutritionPlan] ()
                            val.forEach { v in
                                if String(v.day_uid).contains(text) || "day \(v.day_uid)".contains(text.lowercased()) || "day ".contains(text.lowercased()) || "day 0\(v.day_uid)".contains(text.lowercased()) || String(v.week_uid).contains(text) || "week \(v.week_uid)".contains(text.lowercased()) || "week 0\(v.week_uid)".contains(text.lowercased()) || key.full_name.lowercased().contains(text.lowercased()) {
                                    slice.append(v)
                                }
                            }
                            if !slice.isEmpty {
                                sliceFinal.append(slice)
                            }
                        }
                        isDayWeekFiltered = true
                        isFiltered = true
                        if !sliceFinal.isEmpty {
                            filteredNutritionPlanList.append([key: sliceFinal])
                        }
                    }
                }
            }
            filteredNutritionPlanList = Array(Set(filteredNutritionPlanList)).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                (trainingPlan1.keys.first!.full_name.localizedCaseInsensitiveCompare(trainingPlan2.keys.first!.full_name) == .orderedAscending)
            })
            
            filteredTrainersList.forEach{
                if $0.full_name.contains(text) {
                    filteredTrainersList.append($0)
                    isFiltered = true
                }
            }
        }
        DispatchQueue.main.async {
            if self.isDayWeekFiltered && self.filteredNutritionPlanList != self.initialNutritionList{
                self.dataCell.filteredNutritionPlanList = self.filteredNutritionPlanList
            } else if self.isDayWeekFiltered && self.filteredNutritionPlanList == self.initialNutritionList{
                self.isFiltered = false
                self.filteredNutritionPlanList.removeAll()
            }
            self.tableView.reloadData()
        }
    }
}

