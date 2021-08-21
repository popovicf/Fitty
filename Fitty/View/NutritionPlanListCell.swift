//
//  NutritionPlanListCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import LetterAvatarKit
import Firebase

protocol NutritionPlanListCellSelectionDelegate : AnyObject {
    func getFilteredData(list: [[User: [[NutritionPlan]]]])
}

class NutritionPlanListCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: NutritionPlanListCellSelectionDelegate?
    let service = FirebaseService()
    var trainersList = [User]()
    var nutritionPlanList = [[User: [[NutritionPlan]] ] ]()
    var uids = [String]()
    var days = [String: [Int]]()
    var weeks = [Int]()
    var exercises = [String: [Int]]()
    let avatarImage = LetterAvatarMaker()
    var selectedUser: User?
    var selectedWeek = 0
    var selectedDay = 0
    var set = [[User: [[NutritionPlan]]]]()
    var list = [[User: [[NutritionPlan]]]]()
    var hasTheFunctionCalled : Bool = false {
        didSet{
            hasTheFunctionCalled = true
        }
    }
    var group = DispatchGroup()
    var num = 0
    var filteredNutritionPlanList = [[User: [[NutritionPlan]] ] ]()
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
            self.nutritionPlanList.removeAll()
            if !hasTheFunctionCalled{
                for trainer in trainersList {
                    group.enter()
                    self.service.getUserNutritionPlan(trainer_uid: trainer.uid) { (trainingPlan) in
                        self.nutritionPlanList.append([trainer: trainingPlan])
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                        self.group.leave()
                    } daysArray: { (daysArray) in
                        self.days = daysArray
                    } weeksArray: { (weeksArray) in
                        self.weeks.append(contentsOf: weeksArray)
                    } nutrition_uids: { (exercise_uids) in
                        self.exercises = exercise_uids
                    }
                }
                group.notify(queue: .main) {
                    self.set = Set(self.nutritionPlanList).sorted(by: { (nutritionPlan1, nutritionPlan2) -> Bool in
                        (nutritionPlan2.values.first!.count > nutritionPlan1.values.first!.count)
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
extension NutritionPlanListCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var res = 0
        if !filteredNutritionPlanList.isEmpty {
            filteredNutritionPlanList.forEach {
                res = $0.values.first!.count
            }
            return res
        } else if !list.isEmpty && filteredNutritionPlanList.isEmpty {
            return list[num].values.first!.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cell.nutritionWeekCell, for: indexPath) as! NutritionWeekCell
        
        if filteredNutritionPlanList.isEmpty {
            let weekUID = list[num].values.first?[indexPath.row].first?.week_uid
            let lastWeekUID = list[num].values.first?.last?.last?.week_uid
            let dayUID = list[num].values.first?[indexPath.row].first?.day_uid
            let profilePic = list[num].keys.first?.profile_picture
            if profilePic != "" {
                cell.profilePicture.sd_setImage(with: URL(string: profilePic!), completed: nil)
            } else {
                cell.profilePicture.image = self.avatarImage.setUsername(list[num].keys.first!.full_name).build()?.roundedImage
            }
            cell.fullNameLabel.text = list[num].keys.first?.full_name
            cell.weekDayLabel.text = "Week \(weekUID! < 10 ? "0\(weekUID!)" : "\(weekUID!)") - Day \(dayUID! < 10 ? "0\(dayUID!)" : "\(dayUID!)")"
            cell.weeksPlanLabel.text = "\(lastWeekUID!) week\(lastWeekUID! < 2 ? "" : "s") plan"
        } else {
            let weekUID = filteredNutritionPlanList[section].values.first![indexPath.row].first?.week_uid
            let lastWeekUID = filteredNutritionPlanList[section].values.first!.last?.last?.week_uid
            let dayUID = filteredNutritionPlanList[section].values.first![indexPath.row].first?.day_uid
            let profilePic = filteredNutritionPlanList[section].keys.first?.profile_picture
            
            if profilePic != "" {
                cell.profilePicture.sd_setImage(with: URL(string: profilePic!), completed: nil)
            } else {
                cell.profilePicture.image = self.avatarImage.setUsername(filteredNutritionPlanList[section].keys.first!.full_name).build()?.roundedImage
            }
            cell.fullNameLabel.text = filteredNutritionPlanList[section].keys.first?.full_name
            
            cell.weekDayLabel.text = "Week \(weekUID! < 10 ? "0\(weekUID!)" : "\(weekUID!)") - Day \(dayUID! < 10 ? "0\(dayUID!)" : "\(dayUID!)")"
            cell.weeksPlanLabel.text = "\(lastWeekUID!) week\(lastWeekUID! < 2 ? "" : "s") plan"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if filteredNutritionPlanList.isEmpty {
            selectedUser = list[num].keys.first
            selectedWeek = list[num].values.first![indexPath.row].first!.week_uid
            selectedDay = list[num].values.first![indexPath.row].first!.day_uid
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc =  storyboard.instantiateViewController(withIdentifier: "ShowNutritionPlanVC") as! ShowNutritionPlanViewController
            vc.user = selectedUser!
            vc.weekUID = selectedWeek
            vc.dayUID = selectedDay
            vc.weekData = true
            for child in parentContainerViewController!.children {
                for ch in child.children where ch.restorationIdentifier == "NutritionPlanListVC" {
                    ch.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            selectedUser = filteredNutritionPlanList[section].keys.first
            selectedWeek = filteredNutritionPlanList[section].values.first![indexPath.row].first!.week_uid
            selectedDay = filteredNutritionPlanList[section].values.first![indexPath.row].first!.day_uid
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc =  storyboard.instantiateViewController(withIdentifier: "ShowNutritionPlanVC") as! ShowNutritionPlanViewController
            vc.user = selectedUser!
            vc.weekUID = selectedWeek
            vc.dayUID = selectedDay
            vc.weekData = true
            for child in parentContainerViewController!.children {
                for ch in child.children where ch.restorationIdentifier == "NutritionPlanListVC" {
                    ch.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 130)
    }
}
