//
//  TrainingPlanListCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import LetterAvatarKit
import Firebase

protocol TrainingPlanListCellSelectionDelegate: AnyObject {
    func didSelect(list: [[User : [[TrainingPlan]]]])
    func getFilteredData(list: [[User: [[TrainingPlan]]]])
}

class TrainingPlanListCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: TrainingPlanListCellSelectionDelegate?
    let service = FirebaseService()
    var trainersList = [User]()
    var trainingPlanList = [[User: [[TrainingPlan]] ] ]()
    var uids = [String]()
    var days = [String: [Int]]()
    var weeks = [Int]()
    var exercises = [String: [Int]]()
    let avatarImage = LetterAvatarMaker()
    var selectedUser: User?
    var selectedWeek = 0
    var selectedDay = 0
    var set = [[User: [[TrainingPlan]]]]()
    var list = [[User: [[TrainingPlan]]]]()
    var hasTheFunctionCalled : Bool = false {
        didSet{
            hasTheFunctionCalled = true
        }
    }
    var group = DispatchGroup()
    var num = 0
    var filteredTrainingPlanList = [[User: [[TrainingPlan]] ] ]()
    var indexs = IndexPath()
    var section = 0
    var vc = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.tag = 33
        getData()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getData(){
        FollowService.followingTrainer { (user) in
            self.uids = user
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.getTrainers()
            }
        }
    }
    
    func getTrainingData(){
        if !trainersList.isEmpty {
            self.list.removeAll()
            self.set.removeAll()
            self.trainingPlanList.removeAll()
            if !hasTheFunctionCalled{
                for trainer in trainersList {
                    group.enter()
                    self.service.getUserTrainingPlan(trainer_uid: trainer.uid) { (trainingPlan) in
                        self.trainingPlanList.append([trainer: trainingPlan])
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        self.group.leave()
                    } daysArray: { (daysArray) in
                        self.days = daysArray
                    } weeksArray: { (weeksArray) in
                        self.weeks.append(contentsOf: weeksArray)
                    } exercise_uids: { (exercise_uids) in
                        self.exercises = exercise_uids
                    }
                }
                group.notify(queue: .main) {
                    self.set = Set(self.trainingPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                        (trainingPlan2.values.first!.count > trainingPlan1.values.first!.count)
                    })
                    for s in self.set where !s.values.contains([]){
                        self.list.append(s)
                    }
                    self.delegate?.getFilteredData(list: self.list)
                }
            }
            hasTheFunctionCalled = true
        }
    }
    
    func getTrainers(){
        Firestore.firestore().collection("users").getDocuments { (querySnap, error) in
            for uid in self.uids {
                guard let user = User(userID: uid, snapshot: querySnap) else {return}
                self.trainersList.append(user)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.getTrainingData()
                }
            }
        }
    }
}
extension TrainingPlanListCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CheckReloadDelegate {
    func didChange() {
        DispatchQueue.main.async {
            if !self.trainersList.isEmpty {
                self.list.removeAll()
                self.set.removeAll()
                self.trainingPlanList.removeAll()
                for trainer in self.trainersList {
                    self.group.enter()
                    self.service.getUserTrainingPlan(trainer_uid: trainer.uid) { (trainingPlan) in
                        self.trainingPlanList.append([trainer: trainingPlan])
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        self.group.leave()
                    } daysArray: { (daysArray) in
                        self.days = daysArray
                    } weeksArray: { (weeksArray) in
                        self.weeks.append(contentsOf: weeksArray)
                    } exercise_uids: { (exercise_uids) in
                        self.exercises = exercise_uids
                    }
                    
                }
                self.group.notify(queue: .main) {
                    self.set = Set(self.trainingPlanList).sorted(by: { (trainingPlan1, trainingPlan2) -> Bool in
                        (trainingPlan2.values.first!.count > trainingPlan1.values.first!.count)
                    })
                    for s in self.set where !s.values.contains([]){
                        self.list.append(s)
                    }
                    self.delegate?.didSelect(list: self.list)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var res = 0
        if !filteredTrainingPlanList.isEmpty {
            filteredTrainingPlanList.forEach {
                res = $0.values.first!.count
            }
            return res
        } else if !list.isEmpty && filteredTrainingPlanList.isEmpty {
            return list[num].values.first!.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.weekCell, for: indexPath) as! WeekCell
        
        if filteredTrainingPlanList.isEmpty {
            let weekUID = list[num].values.first?[indexPath.row].first?.week_uid
            let lastWeekUID = list[num].values.first?.last?.last?.week_uid
            let dayUID = list[num].values.first?[indexPath.row].first?.day_uid
            let profilePic = list[num].keys.first?.profile_picture
            for lis in list[num].values.first![indexPath.row] {
                if lis.check == false{
                    cell.checkButtonLabel.isHidden = true
                    break
                } else {
                    cell.checkButtonLabel.isHidden = false
                }
            }
            if profilePic != "" {
                cell.profileImage.sd_setImage(with: URL(string: profilePic!), completed: nil)
            } else {
                cell.profileImage.image = self.avatarImage.setUsername(list[num].keys.first!.full_name).build()?.roundedImage
            }
            cell.trainerNameLabel.text = list[num].keys.first?.full_name
            cell.weekDayLabel.text = "Week \(weekUID! < 10 ? "0\(weekUID!)" : "\(weekUID!)") - Day \(dayUID! < 10 ? "0\(dayUID!)" : "\(dayUID!)")"
            cell.weeksLabel.text = "\(lastWeekUID!) week\(lastWeekUID! < 2 ? "" : "s") plan"
        } else {
            let weekUID = filteredTrainingPlanList[section].values.first![indexPath.row].first?.week_uid
            let lastWeekUID = filteredTrainingPlanList[section].values.first!.last?.last?.week_uid
            let dayUID = filteredTrainingPlanList[section].values.first![indexPath.row].first?.day_uid
            let profilePic = filteredTrainingPlanList[section].keys.first?.profile_picture
            for lis in filteredTrainingPlanList[section].values.first![indexPath.row] {
                if lis.check == false{
                    cell.checkButtonLabel.isHidden = true
                    break
                } else {
                    cell.checkButtonLabel.isHidden = false
                }
            }
            if profilePic != "" {
                cell.profileImage.sd_setImage(with: URL(string: profilePic!), completed: nil)
            } else {
                cell.profileImage.image = self.avatarImage.setUsername(filteredTrainingPlanList[section].keys.first!.full_name).build()?.roundedImage
            }
            cell.trainerNameLabel.text = filteredTrainingPlanList[section].keys.first?.full_name
            cell.weekDayLabel.text = "Week \(weekUID! < 10 ? "0\(weekUID!)" : "\(weekUID!)") - Day \(dayUID! < 10 ? "0\(dayUID!)" : "\(dayUID!)")"
            cell.weeksLabel.text = "\(lastWeekUID!) week\(lastWeekUID! < 2 ? "" : "s") plan"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if filteredTrainingPlanList.isEmpty {
            selectedUser = list[num].keys.first
            selectedWeek = list[num].values.first![indexPath.row].first!.week_uid
            selectedDay = list[num].values.first![indexPath.row].first!.day_uid
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc =  storyboard.instantiateViewController(withIdentifier: "ShowPlanVC") as! ShowPlanViewController
            vc.delegate = self
            vc.user = selectedUser!
            vc.weekUID = selectedWeek
            vc.dayUID = selectedDay
            vc.weekData = true
            for child in parentContainerViewController!.children {
                for ch in child.children where ch.restorationIdentifier == "TrainingPlanListVC" {
                    ch.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            selectedUser = filteredTrainingPlanList[section].keys.first
            selectedWeek = filteredTrainingPlanList[section].values.first![indexPath.row].first!.week_uid
            selectedDay = filteredTrainingPlanList[section].values.first![indexPath.row].first!.day_uid
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc =  storyboard.instantiateViewController(withIdentifier: "ShowPlanVC") as! ShowPlanViewController
            vc.delegate = self
            vc.user = selectedUser!
            vc.weekUID = selectedWeek
            vc.dayUID = selectedDay
            vc.weekData = true
            for child in parentContainerViewController!.children {
                for ch in child.children where ch.restorationIdentifier == "TrainingPlanListVC" {
                    ch.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 130)
    }
}
