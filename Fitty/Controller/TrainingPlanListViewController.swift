//
//  TrainingPlanListViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase

class TrainingPlanListViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let loader = Loader()
    var hasTheFunctionCalled : Bool = false {
        didSet{
            hasTheFunctionCalled = true
        }
    }
    let service = FirebaseService()
    var trainersList = [User]()
    var trainingPlanList = [[User: [[TrainingPlan]] ] ]()
    var uids = [String]()
    var selectedUser: User?
    var res = 0
    var numberOfSections: [Int] = []
    var selectedWeek = 0
    var selectedDay = 0
    var index = [IndexPath]()
    var dataCell = TrainingPlanListCell()
    let label = UILabel()
    let newView = UIView()
    let refreshControl = UIRefreshControl()
    let searchController = UISearchController()
    var filteredTrainingPlanList = [[User: [[TrainingPlan]] ] ]()
    var filteredTrainersList = [User]()
    var isFiltered = false
    var initialTrainingList = [[User: [[TrainingPlan]] ] ]()
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
                    self.tableView.reloadData()
                    self.getTrainers()
                }
            }
        }
    }
    
    func getTrainingData(){
        if !trainersList.isEmpty {
            trainingPlanList.removeAll()
            numberOfSections.removeAll()
            for trainer in trainersList {
                self.service.getUserTrainingPlan(trainer_uid: trainer.uid) { (trainingPlan) in
                    self.trainingPlanList.append([trainer: trainingPlan])
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } daysArray: { (daysArray) in } weeksArray: { (weeksArray) in } exercise_uids: { (exercise_uids) in }
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
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching training plans...", attributes: [.font : UIFont.systemFont(ofSize: 24), .foregroundColor : UIColor.systemOrange] )
        //refreshControl.addSubview(refreshImage)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
}
extension TrainingPlanListViewController: UITableViewDataSource, UITableViewDelegate, TrainingPlanListCellSelectionDelegate{
    func getFilteredData(list: [[User : [[TrainingPlan]]]]) {
        initialTrainingList = list
    }
    
    func didSelect(list: [[User : [[TrainingPlan]]]]) {
        DispatchQueue.main.async {
            FollowService.followingTrainer { (user) in
                self.uids = user
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.getTrainers()
        }
        initialTrainingList = list
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var list = [[User: [[TrainingPlan]] ] ]()
        
        if !filteredTrainingPlanList.isEmpty {
            let set = Set(filteredTrainingPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                (trainingPlan1.keys.first!.full_name.localizedCaseInsensitiveCompare(trainingPlan2.keys.first!.full_name) == .orderedAscending)
            })
            for s in set {
                list.append(s)
            }
        } else if filteredTrainingPlanList.isEmpty && isFiltered == true {
            return 0
        } else {
            let set = Set(trainingPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
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
            label.text = "No training plans"
            label.textColor = .systemOrange
            label.textAlignment = .center
            label.font.withSize(30)
            newView.addSubview(label)
            return 0
        }
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.trainingPlanListCell, for: indexPath) as! TrainingPlanListCell
        dataCell = cell
        cell.delegate = self
        self.indexPath = indexPath
        
        if filteredTrainingPlanList.isEmpty {
            cell.filteredTrainingPlanList.removeAll()
            cell.uids = self.uids
            cell.trainersList = self.trainersList
            cell.trainingPlanList = self.trainingPlanList
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
            cell.filteredTrainingPlanList = self.filteredTrainingPlanList
            cell.section = indexPath.section
            
            DispatchQueue.main.async {
                cell.collectionView.reloadData()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        res = indexPath.section
        var list = [[User: [[TrainingPlan]] ] ]()
        list.removeAll()
        if filteredTrainingPlanList.isEmpty {
            let set = Set(trainingPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                (trainingPlan1.keys.first!.full_name.localizedCaseInsensitiveCompare(trainingPlan2.keys.first!.full_name) == .orderedAscending)
            })
            for s in set where !s.values.contains([]){
                list.append(s)
            }
        } else {
            let set = Set(filteredTrainingPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                (trainingPlan1.keys.first!.full_name.localizedCaseInsensitiveCompare(trainingPlan2.keys.first!.full_name) == .orderedAscending)
            })
            for s in set where !s.values.contains([]){
                list.append(s)
            }
        }
        selectedUser = list[res].keys.first
        performSegue(withIdentifier: Constants.SegueTo.trainingPlanListToShowPlan, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueTo.trainingPlanListToShowPlan {
            let destionation = segue.destination as! ShowPlanViewController
            destionation.user = selectedUser!
        }
    }
}
extension TrainingPlanListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredTrainingPlanList.removeAll()
        filteredTrainersList.removeAll()
        
        if text.isEmpty || text == "" {
            isFiltered = false
            isDayWeekFiltered = false
        } else {
            trainingPlanList.forEach { plan in
                plan.keys.forEach{ key in
                    plan.values.forEach{ value in
                        var sliceFinal = [[TrainingPlan]] ()
                        value.forEach { val in
                            var slice = [TrainingPlan] ()
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
                            filteredTrainingPlanList.append([key: sliceFinal])
                        }
                    }
                }
            }
            filteredTrainingPlanList = Array(Set(filteredTrainingPlanList)).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
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
            if self.isDayWeekFiltered && self.filteredTrainingPlanList != self.initialTrainingList{
                self.dataCell.filteredTrainingPlanList = self.filteredTrainingPlanList
            } else if self.isDayWeekFiltered && self.filteredTrainingPlanList == self.initialTrainingList{
                self.isFiltered = false
                self.filteredTrainingPlanList.removeAll()
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.filteredTrainingPlanList.removeAll()
        self.filteredTrainersList.removeAll()
        isFiltered = false
        isDayWeekFiltered = false
        
        if !self.initialTrainingList.isEmpty {
            self.trainingPlanList = self.initialTrainingList
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
