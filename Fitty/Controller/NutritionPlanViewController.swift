//
//  NutritionPlanViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase
import SwiftyJSON

class NutritionPlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addNewNutritionPlan: UIBarButtonItem!
    var nutritionPlanArray = [ ExpandableNutritionPlan(isExpanded: true, names: [[NutritionPlan]]() )]
    var saveNutritionPlanArray = [ ExpandableNutritionPlan(isExpanded: true, names: [[NutritionPlan]]() )]
    var deletedNutritionPlanArray = [ ExpandableNutritionPlan(isExpanded: true, names: [[NutritionPlan]]() )]
    var user = User()
    var numberOfWeeks = 0
    var numberOfDays: [String: [Int]] = [:]
    var numberOfNutritionPlans: [String: [Int]] = [:]
    let service = FirebaseService()
    var dataCell = NutritionPlanCell()
    var dataCellNew = NutritionPlanCell()
    var indexNew = IndexPath()
    var newIndex = 0
    var indexForDelete = IndexPath()
    var check = false
    var weekUID = 0
    var dayUID = 0
    var nutrition_uid = 0
    var nutrition_plan = ""
    var meal_name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 270
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.Cell.nutritionPlanNibName, bundle: nil), forCellReuseIdentifier: Constants.Cell.nutritionPlanCell)
        self.nutritionPlanArray.removeAll()
        self.saveNutritionPlanArray.removeAll()
        getTrainingData()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        save(data: dataCell)
    }
    func save(data : NutritionPlanCell){
        var list = [[NutritionPlan]]()
        if saveNutritionPlanArray.count > 0 {
            for section in 0...saveNutritionPlanArray.count-1{
                list.append(contentsOf: self.saveNutritionPlanArray[section].names[0...saveNutritionPlanArray[section].names.count-1])
            }
        }
        for l in list {
            service.saveAllDataToNutritionPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, plan: l)
        }
        list = []
        saveNutritionPlanArray = []
        newIndex = 0
    }
    @IBAction func addNewNutritionPlanPressed(_ sender: UIBarButtonItem) {
        if numberOfWeeks != 0 {
            var newArray = [NutritionPlan]()
            let days  = numberOfDays["\(numberOfWeeks)"]?.max() ?? 1
            
            if days < 7 {
                let nutritionPlan = NutritionPlan(week_uid: numberOfWeeks, day_uid: days + 1, meal_name: "", nutrition_plan: "", nutrition_uid: 1, check: false)
                NutritionPlan.setCurrent(nutritionPlan)
                service.updateDataToNutritionPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, week_uid: NutritionPlan.current.week_uid, day_uid: NutritionPlan.current.day_uid, meal_name: NutritionPlan.current.meal_name, nutrition_uid: NutritionPlan.current.nutrition_uid, nutrition_plan: NutritionPlan.current.nutrition_plan, check: NutritionPlan.current.check)
                newArray.append(nutritionPlan)
                self.nutritionPlanArray.append(ExpandableNutritionPlan(isExpanded: true, names: [newArray]))
                numberOfDays["\(numberOfWeeks)"]![0] = days + 1
                numberOfNutritionPlans.updateValue([NutritionPlan.current.nutrition_uid], forKey: "\(nutritionPlanArray.count)")
            } else {
                numberOfWeeks += 1
                let nutritionPlan = NutritionPlan(week_uid: numberOfWeeks, day_uid: 1, meal_name: "", nutrition_plan: "", nutrition_uid: 1, check: false)
                NutritionPlan.setCurrent(nutritionPlan)
                service.setDataToNutritionPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, week_uid: NutritionPlan.current.week_uid, day_uid: NutritionPlan.current.day_uid, meal_name: NutritionPlan.current.meal_name, nutrition_uid: NutritionPlan.current.nutrition_uid, nutrition_plan: NutritionPlan.current.nutrition_plan, check: NutritionPlan.current.check)
                newArray.append(nutritionPlan)
                self.nutritionPlanArray.append(ExpandableNutritionPlan(isExpanded: true, names: [newArray]))
                numberOfDays.updateValue([1], forKey: "\(numberOfWeeks)")
                numberOfNutritionPlans["\(nutritionPlanArray.count)"]?.append(TrainingPlan.current.exercise_uid)
            }
        } else {
            self.numberOfWeeks += 1
            let nutritionPlan = NutritionPlan(week_uid: 1, day_uid: 1, meal_name: "", nutrition_plan: "", nutrition_uid: 1, check: false)
            NutritionPlan.setCurrent(nutritionPlan)
            service.setDataToNutritionPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, week_uid: NutritionPlan.current.week_uid, day_uid: NutritionPlan.current.day_uid, meal_name: NutritionPlan.current.meal_name, nutrition_uid: NutritionPlan.current.nutrition_uid, nutrition_plan: NutritionPlan.current.nutrition_plan, check: NutritionPlan.current.check)
            self.nutritionPlanArray.append(ExpandableNutritionPlan(isExpanded: true, names: [[nutritionPlan]]))
            self.numberOfDays.updateValue([1], forKey: "\(self.numberOfWeeks)")
            numberOfNutritionPlans.updateValue([1], forKey: "\(nutritionPlanArray.count)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getTrainingData(){
        self.service.getDataFromNutritionPlan(user_uid: self.user.uid, trainer_uid: Auth.auth().currentUser!.uid) { (saved_plan) in
            if !saved_plan.isEmpty {
                for plan in saved_plan {
                    self.nutritionPlanArray.append(ExpandableNutritionPlan(isExpanded: true, names: [plan]))
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } daysArray: { (days) in
            self.numberOfDays = days
        } weeksArray: { (weeks) in
            self.numberOfWeeks = weeks.max() ?? 0
        } nutrition_uids: { (nutrition_plan) in
            self.numberOfNutritionPlans = nutrition_plan
        }
    }
    
    func getNumberOfNutritionPlans(){
        self.service.getDataFromNutritionPlan(user_uid: self.user.uid, trainer_uid: Auth.auth().currentUser!.uid) { (saved_plan) in
            if !saved_plan.isEmpty {
                for _ in saved_plan {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } daysArray: { (days) in } weeksArray: { (weeks) in } nutrition_uids: { (nutrition) in
            self.numberOfNutritionPlans = nutrition
        }
    }
}
extension NutritionPlanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.init(cgColor: #colorLiteral(red: 0.8677101209, green: 0.8539167511, blue: 0.8765505396, alpha: 1))
        }
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = nil
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var indexPath = IndexPath()
        for row in nutritionPlanArray[section].names.indices {
            indexPath = IndexPath(row: row, section: section)
        }
        if !nutritionPlanArray[section].isExpanded {
            return 0
        }
        return nutritionPlanArray[section].names[indexPath.row].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return nutritionPlanArray.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var indexPath = IndexPath()
        for row in nutritionPlanArray[section].names.indices {
            indexPath = IndexPath(row: row, section: section)
        }
        indexForDelete = indexPath
        let nutritionPlan = nutritionPlanArray[indexPath.section].names[indexPath.row]
        let button = UIButton(type: .system)
        for plan in nutritionPlan {
            if nutritionPlanArray[section].isExpanded {
                button.setTitle("Week \(plan.week_uid) - Day \(plan.day_uid)    -    Hide", for: .normal)
            } else {
                button.setTitle("Week \(plan.week_uid) - Day \(plan.day_uid)    -    Show", for: .normal)
            }
        }
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        button.tag = section
        return button
    }
    @objc func handleExpandClose(button: UIButton){
        let section = button.tag
        var indexPath = IndexPath()
        var indexPaths = [IndexPath]()
        for row in nutritionPlanArray[section].names[indexForDelete.row].indices {
            indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        let nutritionPlan = nutritionPlanArray[indexPath.section].names[indexForDelete.row]
        let isExpanded = nutritionPlanArray[section].isExpanded
        nutritionPlanArray[section].isExpanded = !isExpanded
        for plan in nutritionPlan {
            if isExpanded {
                button.setTitle("Week \(plan.week_uid) - Day \(plan.day_uid)    -    Show", for: .normal)
                tableView.deleteRows(at: indexPaths, with: .fade)
                break
            } else {
                button.setTitle("Week \(plan.week_uid) - Day \(plan.day_uid)    -    Hide", for: .normal)
                tableView.insertRows(at: indexPaths, with: .fade)
                break
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.nutritionPlanCell, for: indexPath) as! NutritionPlanCell
        dataCell = cell
        cell.delegate = self
        let nutritionPlan = nutritionPlanArray[indexPath.section].names
        for plan in nutritionPlan {
            cell.nutrition = plan[indexPath.row]
            cell.mealName.delegate = self
            cell.mealTextView.delegate = self
            cell.mealName.text = plan[indexPath.row].meal_name
            if plan[indexPath.row].nutrition_plan != "" && plan[indexPath.row].nutrition_plan != "Create daily nutrition plan" {
                cell.mealTextView.textColor = UIColor.black
                cell.mealTextView.text = plan[indexPath.row].nutrition_plan
            } else if plan[indexPath.row].nutrition_plan == "Create daily nutrition plan" {
                cell.mealTextView.textColor = UIColor.lightGray
                cell.mealTextView.text = "Create daily nutrition plan"
            } else {
                cell.mealTextView.textColor = UIColor.lightGray
                cell.mealTextView.text = "Create daily nutrition plan"
            }
            cell.mealName.tag = 0
            cell.mealTextView.tag = 1
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NutritionPlanCell
        var week_uid = 0
        if indexPath.section > 5 && indexPath.section != 6 && (indexPath.section + 1) % 7 != 0 {
            week_uid = (indexPath.section / 7 ) + 1
        } else if (indexPath.section + 1) % 7 == 0 {
            week_uid = (indexPath.section + 1)/7 + (indexPath.section + 1)%7
        } else {
            week_uid = 1
        }
        let day_uid = nutritionPlanArray[indexPath.section].names[0][indexPath.row].day_uid
        let meal_name = cell.mealName.text ?? ""
        let nutrition_uid = nutritionPlanArray[indexPath.section].names[0][indexPath.row].nutrition_uid
        let nutrition_plan = cell.mealTextView.text ?? ""
        
        let newNutritionPlan = NutritionPlan(week_uid: week_uid, day_uid: day_uid, meal_name: meal_name, nutrition_plan: nutrition_plan, nutrition_uid: nutrition_uid, check: false)
        
        NutritionPlan.setCurrent(newNutritionPlan)
        nutritionPlanArray[indexPath.section].names[0][indexPath.row] = newNutritionPlan
        saveNutritionPlanArray.insert(nutritionPlanArray[indexPath.section], at: newIndex)
        newIndex += 1
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section > 5 && indexPath.section != 6 && (indexPath.section + 1) % 7 != 0 {
            if numberOfWeeks == (indexPath.section / 7 ) + 1 {
                return .delete
            } else {
                return .none
            }
        } else if (indexPath.section + 1) % 7 == 0 {
            if numberOfWeeks == (indexPath.section + 1)/7 + (indexPath.section + 1)%7 {
                return .delete
            } else {
                return .none
            }
        }
        else {
            if indexPath.section < 6 && numberOfWeeks == 1 {
                return .delete
            } else {
                return .none
            }
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let indexToRemove = indexPath.row
        let nutritionToDelete = nutritionPlanArray[indexPath.section].names[0][indexToRemove]
        if editingStyle == .delete {
            tableView.beginUpdates()
            if nutritionToDelete != nutritionPlanArray[indexPath.section].names[0].last! {
                nutritionPlanArray[indexPath.section].names[0].remove(at: indexPath.row)
                numberOfNutritionPlans["\(indexPath.section+1)"]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                let updatedArray = nutritionPlanArray[indexPath.section].names[0][indexToRemove...]
                var res: [Int] = []
                for array in updatedArray {
                    res.append(array.nutrition_uid - 1)
                }
                res.sorted().forEach{r in nutritionPlanArray[indexPath.section].names[0][r-1].nutrition_uid = r}
                
                Firestore.firestore().collection("nutrition_plan").document(user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").getDocument { (docSnap, error) in
                    var dataValue = [[String: Any]]()
                    if let snapData = docSnap?.data() {
                        var removedKeys = [Int]()
                        var updateKeys = [Int]()
                        for key in snapData.keys where key == "day_\(nutritionToDelete.day_uid)"{
                            let data = snapData[key] as! [[String: Any]]
                            for d in data {
                                if d["nutrition_uid"] as! Int == nutritionToDelete.nutrition_uid {
                                    Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").updateData([key: FieldValue.arrayRemove([ ["meal_name": nutritionToDelete.meal_name, "nutrition_uid": nutritionToDelete.nutrition_uid, "nutrition_plan": nutritionToDelete.nutrition_plan, "check": nutritionToDelete.check] ]) ])
                                    removedKeys.append(d["nutrition_uid"] as! Int)
                                } else {
                                    updateKeys.append(d["nutrition_uid"] as! Int)
                                    dataValue.append(d)
                                }
                            }
                        }
                        let removedKey = removedKeys.max()!
                        let updatedKey = updateKeys.filter { $0 > removedKey }.sorted()
                        var dataValueKey = dataValue.filter { $0["nutrition_uid"] as! Int > removedKey }.sorted { (first, second) -> Bool in
                            return second["nutrition_uid"] as! Int > first["nutrition_uid"] as! Int
                        }
                        let dataValueToCopy = dataValue.filter { removedKey > $0["nutrition_uid"] as! Int }.sorted { (first, second) -> Bool in
                            return second["nutrition_uid"] as! Int > first["nutrition_uid"] as! Int
                        }
                        var dataValueKeyNew = [[String:Any]]()
                        var dayKey = 0
                        var i = 0
                        dataValueKey.forEach{ key in
                            Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").updateData(["day_\(nutritionToDelete.day_uid)" : [] ]) }
                        dataValueToCopy.forEach{ key in
                            Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").setData(["day_\(nutritionToDelete.day_uid)" : FieldValue.arrayUnion([key]) ], merge: true)
                        }
                        updatedKey.forEach { upKey in
                            dayKey = upKey
                            dataValueKey[i]["nutrition_uid"] = dayKey-1
                            dataValueKeyNew.append(dataValueKey[i])
                            Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").setData(["day_\(nutritionToDelete.day_uid)" : FieldValue.arrayUnion([dataValueKeyNew[i] ]) ], merge: true)
                            i += 1
                        }
                    }
                }
            } else {
                nutritionPlanArray[indexPath.section].names[0].remove(at: indexPath.row)
                numberOfNutritionPlans["\(indexPath.section+1)"]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").updateData(["day_\(nutritionToDelete.day_uid)": FieldValue.arrayRemove([ ["meal_name": nutritionToDelete.meal_name, "nutrition_uid": nutritionToDelete.nutrition_uid, "nutrition_plan": nutritionToDelete.nutrition_plan, "check": nutritionToDelete.check] ]) ])
                self.getNumberOfNutritionPlans()
            }
            
            if nutritionPlanArray[indexPath.section].names[0].count == 0 {
                if nutritionPlanArray.lastIndex(of: nutritionPlanArray[indexPath.section])! + 1 != nutritionPlanArray.count {
                    numberOfDays["\(numberOfWeeks)"]?[0] -= 1
                    nutritionPlanArray.remove(at: indexPath.section)
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                    Firestore.firestore().collection("nutrition_plan").document(user.uid).collection(Auth.auth().currentUser!.uid).getDocuments { (docSnap, error) in
                        var dataToSave = [String : [Any] ]()
                        if let snapData = docSnap?.documents {
                            var removedKeys = [Int]()
                            var updateKeys = [Int]()
                            for snap in snapData where snap.documentID == "week_\(nutritionToDelete.week_uid)"{
                                let data = snap.data()
                                for key in data.keys {
                                    if key == "day_\(nutritionToDelete.day_uid)" {
                                        removedKeys.append(Int(key.split(separator: "_")[1])!)
                                    } else {
                                        dataToSave.updateValue(data[key] as! [Any], forKey: key)
                                        updateKeys.append(Int(key.split(separator: "_")[1])!)
                                    }
                                }
                            }
                            let removedKey = removedKeys.max()!
                            let updatedKey = updateKeys.filter { $0 > removedKey }.sorted()
                            let dataValueKey = dataToSave.filter { Int($0.key.split(separator: "_")[1].description)! > removedKey }.sorted { (first, second) -> Bool in
                                return Int(second.key.split(separator: "_")[1].description)! > Int(first.key.split(separator: "_")[1].description)!
                            }
                            self.deletedNutritionPlanArray.removeAll()
                            var i = 0
                            updatedKey.forEach { key in
                                let json = JSON(dataValueKey[i].value)
                                for nutritionNumber in 0...json.count-1 {
                                    let newNutritionPlan = NutritionPlan(week_uid: nutritionToDelete.week_uid, day_uid: key-1, meal_name: json[nutritionNumber]["meal_name"].stringValue, nutrition_plan: json[nutritionNumber]["nutrition_plan"].stringValue, nutrition_uid: json[nutritionNumber]["nutrition_uid"].intValue, check: false)
                                    var newArray = [NutritionPlan]()
                                    newArray.append(newNutritionPlan)
                                    Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").updateData(["day_\(key-1)": [] ])
                                    Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").updateData(["day_\(key-1)": FieldValue.arrayUnion(dataValueKey[i].value) ])
                                }
                                i += 1
                            }
                            self.nutritionPlanArray.removeAll()
                            self.getTrainingData()
                            
                            Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").updateData(["day_\(updatedKey.max()!)": FieldValue.delete()])
                        }
                    }
                }  else {
                    if nutritionToDelete.day_uid == 1 {
                        numberOfWeeks -= 1
                        nutritionPlanArray.remove(at: indexPath.section)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                        Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").delete()
                    } else {
                        numberOfDays["\(numberOfWeeks)"]?[0] -= 1
                        nutritionPlanArray.remove(at: indexPath.section)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                        Firestore.firestore().collection("nutrition_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(nutritionToDelete.week_uid)").updateData(["day_\(nutritionToDelete.day_uid)": FieldValue.delete() ])
                    }
                }
            }
            tableView.endUpdates()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
extension NutritionPlanViewController: NutritionPlanCellDelegate {
    func nutritionPlanCell(_ nutritionPlanCell: NutritionPlanCell, newNutritionButtonPressed nutrition: NutritionPlan) {
        self.dataCell.mealName.endEditing(true)
        self.dataCell.mealTextView.endEditing(true)

        guard let indexPath = self.tableView.indexPath(for: nutritionPlanCell) else { return }
        let nutrition = numberOfNutritionPlans["\(indexPath.section+1)"]
        let nutritionUID = nutrition?.max() ?? 0
        
        var newArray = [NutritionPlan]()
        var nutritionPlan = NutritionPlan(week_uid: 0, day_uid: 0, meal_name: "", nutrition_plan: "", nutrition_uid: 0, check: false)
        if indexPath.section > 5 && indexPath.section != 6 && (indexPath.section + 1) % 7 != 0 {
            nutritionPlan = NutritionPlan(week_uid: (indexPath.section / 7 ) + 1, day_uid: (indexPath.section + 1) % 7, meal_name: "", nutrition_plan: "", nutrition_uid: nutritionUID+1, check: false)
            NutritionPlan.setCurrent(nutritionPlan)
        } else if (indexPath.section + 1) % 7 == 0 {
            nutritionPlan = NutritionPlan(week_uid: (indexPath.section + 1)/7 + (indexPath.section + 1)%7, day_uid: (indexPath.section + 1) / ((indexPath.section + 1)/7 + (indexPath.section + 1)%7), meal_name: "", nutrition_plan: "", nutrition_uid: nutritionUID+1, check: false)
            NutritionPlan.setCurrent(nutritionPlan)
        }
        else {
            nutritionPlan = NutritionPlan(week_uid: numberOfWeeks, day_uid: indexPath.section + 1, meal_name: "", nutrition_plan: "", nutrition_uid: nutritionUID+1, check: false)
            NutritionPlan.setCurrent(nutritionPlan)
        }
        self.service.updateDataToNutritionPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, week_uid: NutritionPlan.current.week_uid, day_uid: NutritionPlan.current.day_uid, meal_name: NutritionPlan.current.meal_name, nutrition_uid: NutritionPlan.current.nutrition_uid, nutrition_plan: NutritionPlan.current.nutrition_plan, check: NutritionPlan.current.check)
        newArray.append(nutritionPlan)
        self.nutritionPlanArray[indexPath.section].names[0].append(contentsOf: newArray)
        
        numberOfNutritionPlans["\(indexPath.section+1)"]?.append(NutritionPlan.current.nutrition_uid)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func selectedTextField(_ nutritionPlanCell: NutritionPlanCell, textField: UITextField) {
        guard let indexPath = self.tableView.indexPath(for: nutritionPlanCell) else { return }
        dataCellNew = nutritionPlanCell
        indexNew = indexPath
        let nutritionPlan = nutritionPlanArray[indexPath.section].names
        for plan in nutritionPlan {
            dayUID = plan[indexPath.row].day_uid
            weekUID = plan[indexPath.row].week_uid
            nutrition_uid = nutritionPlanArray[indexPath.section].names[0][indexPath.row].nutrition_uid
            meal_name = textField.text!
            nutrition_plan = plan[indexPath.row].nutrition_plan
            check = false
        }
        let newNutritionPlan = NutritionPlan(week_uid: weekUID, day_uid: dayUID, meal_name: meal_name, nutrition_plan: nutrition_plan, nutrition_uid: nutrition_uid, check: check)
        NutritionPlan.setCurrent(newNutritionPlan)
        nutritionPlanArray[indexPath.section].names[0][indexPath.row] = newNutritionPlan
        
        saveNutritionPlanArray.insert(nutritionPlanArray[indexPath.section], at: newIndex)
        newIndex += 1
        save(data: dataCell)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    func selectedTextView(_ nutritionPlanCell: NutritionPlanCell, textField: UITextView) {
        guard let indexPath = self.tableView.indexPath(for: nutritionPlanCell) else { return }
        dataCellNew = nutritionPlanCell
        indexNew = indexPath
        let nutritionPlan = nutritionPlanArray[indexPath.section].names
        for plan in nutritionPlan {
            dayUID = plan[indexPath.row].day_uid
            weekUID = plan[indexPath.row].week_uid
            nutrition_uid = nutritionPlanArray[indexPath.section].names[0][indexPath.row].nutrition_uid
            meal_name = plan[indexPath.row].meal_name
            nutrition_plan = textField.text
            check = false
        }
        let newNutritionPlan = NutritionPlan(week_uid: weekUID, day_uid: dayUID, meal_name: meal_name, nutrition_plan: nutrition_plan, nutrition_uid: nutrition_uid, check: check)
        NutritionPlan.setCurrent(newNutritionPlan)
        nutritionPlanArray[indexPath.section].names[0][indexPath.row] = newNutritionPlan
        
        saveNutritionPlanArray.insert(nutritionPlanArray[indexPath.section], at: newIndex)
        newIndex += 1
        save(data: dataCell)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}
extension NutritionPlanViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.view.reloadInputViews()
        self.selectedTextField(dataCellNew, textField: textField)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.selectedTextField(dataCellNew, textField: textField)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.selectedTextField(dataCellNew, textField: textField)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        if updatedText.isEmpty {
            textView.text = "Create daily nutrition plan"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
        else {
            return true
        }
        return false
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.selectedTextView(dataCell, textField: textView)
    }
}
