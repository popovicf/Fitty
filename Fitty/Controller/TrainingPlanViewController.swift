//
//  TrainingPlanViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase
import SwiftyJSON

class TrainingPlanViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newWeekButton: UIBarButtonItem!
    var trainingPlanArray = [ ExpandableNames(isExpanded: true, names: [[TrainingPlan]]() )]
    var saveTrainingPlanArray = [ ExpandableNames(isExpanded: true, names: [[TrainingPlan]]() )]
    var deletedTrainingPlanArray = [ ExpandableNames(isExpanded: true, names: [[TrainingPlan]]() )]
    var user = User()
    var numberOfWeeks = 0
    var numberOfDays: [String: [Int]] = [:]
    var numberOfExercises: [String: [Int]] = [:]
    let service = FirebaseService()
    var dataCell = TrainingPlanCell()
    var dataCellNew = TrainingPlanCell()
    var indexNew = IndexPath()
    var newIndex = 0
    var indexForDelete = IndexPath()
    var check = false
    var weekUID = 0
    var dayUID = 0
    var videoURL = ""
    var exercise_uid = 0
    var exercise = ""
    var rounds = 0
    var reps = 0
    var load = 0
    var loadType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 260
        tableView.register(UINib(nibName: Constants.Cell.trainingPlanNibName, bundle: nil), forCellReuseIdentifier: Constants.Cell.trainingPlanCell)
        self.trainingPlanArray.removeAll()
        self.saveTrainingPlanArray.removeAll()
        getTrainingData()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func newWeekPressed(_ sender: UIBarButtonItem) {
        if numberOfWeeks != 0 {
            var newArray = [TrainingPlan]()
            let days  = numberOfDays["\(numberOfWeeks)"]?.max() ?? 1
            
            if days < 7 {
                let trainingPlan = TrainingPlan(day_uid: days + 1, week_uid: numberOfWeeks, exercise_uid: 1, exercise: "", rounds: 0, reps: 0, load: 0, load_unit: "kg", videoURL: "", check: false)
                TrainingPlan.setCurrent(trainingPlan)
                service.updateDataToTrainingPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, week_uid: TrainingPlan.current.week_uid, day_uid: TrainingPlan.current.day_uid, exercise: TrainingPlan.current.exercise, exercise_uid: TrainingPlan.current.exercise_uid, rounds: TrainingPlan.current.rounds, reps: TrainingPlan.current.reps, load: TrainingPlan.current.load, load_unit: TrainingPlan.current.load_unit, videoURL: TrainingPlan.current.videoURL)
                newArray.append(trainingPlan)
                self.trainingPlanArray.append(ExpandableNames(isExpanded: true, names: [newArray]))
                numberOfDays["\(numberOfWeeks)"]![0] = days + 1
                numberOfExercises.updateValue([TrainingPlan.current.exercise_uid], forKey: "\(trainingPlanArray.count)")
            } else {
                numberOfWeeks += 1
                let trainingPlan = TrainingPlan(day_uid: 1, week_uid: numberOfWeeks, exercise_uid: 1, exercise: "", rounds: 0, reps: 0, load: 0, load_unit: "kg", videoURL: "", check: false)
                TrainingPlan.setCurrent(trainingPlan)
                service.setDataToTrainingPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, week_uid: TrainingPlan.current.week_uid, day_uid: TrainingPlan.current.day_uid, exercise: TrainingPlan.current.exercise, exercise_uid: TrainingPlan.current.exercise_uid, rounds: TrainingPlan.current.rounds, reps: TrainingPlan.current.reps, load: TrainingPlan.current.load, load_unit: TrainingPlan.current.load_unit, videoURL: TrainingPlan.current.videoURL)
                newArray.append(trainingPlan)
                self.trainingPlanArray.append(ExpandableNames(isExpanded: true, names: [newArray]))
                numberOfDays.updateValue([1], forKey: "\(numberOfWeeks)")
                numberOfExercises["\(trainingPlanArray.count)"]?.append(TrainingPlan.current.exercise_uid)
            }
        } else {
            self.numberOfWeeks += 1
            let trainingPlan = TrainingPlan(day_uid: 1, week_uid: 1, exercise_uid: 1, exercise: "", rounds: 1, reps: 1, load: 1, load_unit: "kg", videoURL: "", check: false)
            TrainingPlan.setCurrent(trainingPlan)
            service.setDataToTrainingPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, week_uid: TrainingPlan.current.week_uid, day_uid: TrainingPlan.current.day_uid, exercise: TrainingPlan.current.exercise, exercise_uid: TrainingPlan.current.exercise_uid, rounds: TrainingPlan.current.rounds, reps: TrainingPlan.current.reps, load: TrainingPlan.current.load, load_unit: TrainingPlan.current.load_unit, videoURL: TrainingPlan.current.videoURL)
            self.trainingPlanArray.append(ExpandableNames(isExpanded: true, names: [[trainingPlan]]))
            self.numberOfDays.updateValue([1], forKey: "\(self.numberOfWeeks)")
            numberOfExercises.updateValue([1], forKey: "\(trainingPlanArray.count)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        save(data: dataCell)
    }
    func save(data : TrainingPlanCell){
        var list = [[TrainingPlan]]()
        if saveTrainingPlanArray.count > 0 {
            for section in 0...saveTrainingPlanArray.count-1{
                list.append(contentsOf: self.saveTrainingPlanArray[section].names[0...saveTrainingPlanArray[section].names.count-1])
            }
        }
        for l in list {
            service.saveAllDataToTrainingPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, plan: l)
        }
        list = []
        saveTrainingPlanArray = []
        newIndex = 0
    }
    func setData(data : TrainingPlanCell){
        var list = [[TrainingPlan]]()
        if saveTrainingPlanArray.count > 0 {
            for section in 0...saveTrainingPlanArray.count-1{
                list.append(contentsOf: self.saveTrainingPlanArray[section].names[0...saveTrainingPlanArray[section].names.count-1])
            }
        }
        for l in list {
            service.setAllDataToTrainingPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, plan: l)
        }
        list = []
        saveTrainingPlanArray = []
    }
    func getTrainingData(){
        self.service.getDataFromTrainingPlan(user_uid: self.user.uid, trainer_uid: Auth.auth().currentUser!.uid) { (saved_plan) in
            if !saved_plan.isEmpty {
                for plan in saved_plan {
                    self.trainingPlanArray.append(ExpandableNames(isExpanded: true, names: [plan]))
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } daysArray: { (days) in
            self.numberOfDays = days
        } weeksArray: { (weeks) in
            self.numberOfWeeks = weeks.max() ?? 0
        } exercise_uids: { (exercise) in
            self.numberOfExercises = exercise
        }
    }
    func getNumberOfExercises(){
        self.service.getDataFromTrainingPlan(user_uid: self.user.uid, trainer_uid: Auth.auth().currentUser!.uid) { (saved_plan) in
            if !saved_plan.isEmpty {
                for _ in saved_plan {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } daysArray: { (days) in } weeksArray: { (weeks) in } exercise_uids: { (exercise) in
            self.numberOfExercises = exercise
        }
    }
}
extension TrainingPlanViewController: UITableViewDelegate {
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
}
extension TrainingPlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var indexPath = IndexPath()
        for row in trainingPlanArray[section].names.indices {
            indexPath = IndexPath(row: row, section: section)
        }
        if !trainingPlanArray[section].isExpanded {
            return 0
        }
        return trainingPlanArray[section].names[indexPath.row].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return trainingPlanArray.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var indexPath = IndexPath()
        for row in trainingPlanArray[section].names.indices {
            indexPath = IndexPath(row: row, section: section)
        }
        indexForDelete = indexPath
        let trainingPlan = trainingPlanArray[indexPath.section].names[indexPath.row]
        let button = UIButton(type: .system)
        for plan in trainingPlan {
            if trainingPlanArray[section].isExpanded {
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
        for row in trainingPlanArray[section].names[indexForDelete.row].indices {
            indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        let trainingPlan = trainingPlanArray[indexPath.section].names[indexForDelete.row]
        let isExpanded = trainingPlanArray[section].isExpanded
        trainingPlanArray[section].isExpanded = !isExpanded
        for plan in trainingPlan {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.trainingPlanCell,  for: indexPath) as! TrainingPlanCell
        dataCell = cell
        cell.delegate = self
        let trainingPlan = trainingPlanArray[indexPath.section].names
        for plan in trainingPlan {
            cell.training = plan[indexPath.row]
            cell.exerciseTextField.delegate = self
            cell.exerciseTextField.tag = indexPath.row
            cell.roundsTextField.delegate = self
            cell.roundsTextField.tag = indexPath.row
            cell.repsTextField.delegate = self
            cell.repsTextField.tag = indexPath.row
            cell.loadTextField.delegate = self
            cell.loadTextField.tag = indexPath.row
            cell.loadTypeTextField.delegate = self
            cell.loadTypeTextField.tag = indexPath.row
            cell.videoTextField.delegate = self
            cell.videoTextField.tag = indexPath.row
            cell.dayTextLabel.text = "Day \(plan[indexPath.row].day_uid)"
            cell.dayTextLabel.isHidden = true
            cell.exerciseTextField.text = plan[indexPath.row].exercise
            cell.roundsTextField.text = String(plan[indexPath.row].rounds)
            cell.repsTextField.text = String(plan[indexPath.row].reps)
            cell.loadTextField.text = String(plan[indexPath.row].load)
            cell.loadTypeTextField.text = plan[indexPath.row].load_unit != "" ? plan[indexPath.row].load_unit : ""
            cell.videoTextField.text = plan[indexPath.row].videoURL
            cell.exerciseTextField.tag = 0
            cell.roundsTextField.tag = 1
            cell.repsTextField.tag = 2
            cell.loadTextField.tag = 3
            cell.loadTypeTextField.tag = 4
            cell.videoTextField.tag = 5
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TrainingPlanCell
        var week_uid = 0
        if indexPath.section > 5 && indexPath.section != 6 && (indexPath.section + 1) % 7 != 0 {
            week_uid = (indexPath.section / 7 ) + 1
        } else if (indexPath.section + 1) % 7 == 0 {
            week_uid = (indexPath.section + 1)/7 + (indexPath.section + 1)%7
        } else {
            week_uid = 1
        }
        let day_uid = (cell.dayTextLabel.text?.split(separator: " ")[1])!.description
        let exercise = cell.exerciseTextField.text ?? ""
        let exercise_uid = trainingPlanArray[indexPath.section].names[0][indexPath.row].exercise_uid
        let rounds = cell.roundsTextField.text ?? ""
        let reps = cell.repsTextField.text ?? ""
        let load = cell.loadTextField.text ?? ""
        let load_unit = cell.loadTypeTextField.text ?? ""
        let video = cell.videoTextField.text ?? ""
        let newTrainingPlan = TrainingPlan(day_uid: Int(String(day_uid))!, week_uid: week_uid, exercise_uid: exercise_uid, exercise:  exercise, rounds: Int(rounds) ?? 0, reps: Int(reps) ?? 0, load: Int(load) ?? 0, load_unit: load_unit, videoURL: video, check: false)
        TrainingPlan.setCurrent(newTrainingPlan)
        trainingPlanArray[indexPath.section].names[0][indexPath.row] = newTrainingPlan
        saveTrainingPlanArray.insert(trainingPlanArray[indexPath.section], at: newIndex)
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
        let trainingToDelete = trainingPlanArray[indexPath.section].names[0][indexToRemove]
        if editingStyle == .delete {
            tableView.beginUpdates()
            
            
            if trainingToDelete != trainingPlanArray[indexPath.section].names[0].last! {
                
                trainingPlanArray[indexPath.section].names[0].remove(at: indexPath.row)
                numberOfExercises["\(indexPath.section+1)"]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                let updatedArray = trainingPlanArray[indexPath.section].names[0][indexToRemove...]
                var res: [Int] = []
                
                for array in updatedArray {
                    res.append(array.exercise_uid - 1)
                }
                res.sorted().forEach{r in trainingPlanArray[indexPath.section].names[0][r-1].exercise_uid = r}
                
                Firestore.firestore().collection("training_plan").document(user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").getDocument { (docSnap, error) in
                    var dataValue = [[String: Any]]()
                    if let snapData = docSnap?.data() {
                        var removedKeys = [Int]()
                        var updateKeys = [Int]()
                        for key in snapData.keys where key == "day_\(trainingToDelete.day_uid)"{
                            let data = snapData[key] as! [[String: Any]]
                            for d in data {
                                if d["exercise_uid"] as! Int == trainingToDelete.exercise_uid {
                                    Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").updateData([key: FieldValue.arrayRemove([ ["exercise": trainingToDelete.exercise, "exercise_uid": trainingToDelete.exercise_uid, "load": trainingToDelete.load, "load_unit": trainingToDelete.load_unit, "rounds": trainingToDelete.rounds, "reps": trainingToDelete.reps, "videoURL": trainingToDelete.videoURL] ]) ])
                                    removedKeys.append(d["exercise_uid"] as! Int)
                                } else {
                                    updateKeys.append(d["exercise_uid"] as! Int)
                                    dataValue.append(d)
                                }
                            }
                        }
                        let removedKey = removedKeys.max()!
                        let updatedKey = updateKeys.filter { $0 > removedKey }.sorted()
                        var dataValueKey = dataValue.filter { $0["exercise_uid"] as! Int > removedKey }.sorted { (first, second) -> Bool in
                            return second["exercise_uid"] as! Int > first["exercise_uid"] as! Int
                        }
                        let dataValueToCopy = dataValue.filter { removedKey > $0["exercise_uid"] as! Int }.sorted { (first, second) -> Bool in
                            return second["exercise_uid"] as! Int > first["exercise_uid"] as! Int
                        }
                        var dataValueKeyNew = [[String:Any]]()
                        var dayKey = 0
                        var i = 0
                        dataValueKey.forEach{ key in
                            Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").updateData(["day_\(trainingToDelete.day_uid)" : [] ]) }
                        dataValueToCopy.forEach{ key in
                            Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").setData(["day_\(trainingToDelete.day_uid)" : FieldValue.arrayUnion([key]) ], merge: true)
                        }
                        updatedKey.forEach { upKey in
                            dayKey = upKey
                            dataValueKey[i]["exercise_uid"] = dayKey-1
                            dataValueKeyNew.append(dataValueKey[i])
                            Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").setData(["day_\(trainingToDelete.day_uid)" : FieldValue.arrayUnion([dataValueKeyNew[i] ]) ], merge: true)
                            i += 1
                        }
                    }
                }
            } else {
                trainingPlanArray[indexPath.section].names[0].remove(at: indexPath.row)
                numberOfExercises["\(indexPath.section+1)"]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").updateData(["day_\(trainingToDelete.day_uid)": FieldValue.arrayRemove([ ["exercise": trainingToDelete.exercise, "exercise_uid": trainingToDelete.exercise_uid, "load": trainingToDelete.load, "load_unit": trainingToDelete.load_unit, "rounds": trainingToDelete.rounds, "reps": trainingToDelete.reps, "videoURL": trainingToDelete.videoURL] ]) ])
                
                self.getNumberOfExercises()
            }
            if trainingPlanArray[indexPath.section].names[0].count == 0 {
                if trainingPlanArray.lastIndex(of: trainingPlanArray[indexPath.section])! + 1 != trainingPlanArray.count {
                    numberOfDays["\(numberOfWeeks)"]?[0] -= 1
                    trainingPlanArray.remove(at: indexPath.section)
                    tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                    Firestore.firestore().collection("training_plan").document(user.uid).collection(Auth.auth().currentUser!.uid).getDocuments { (docSnap, error) in
                        var dataToSave = [String : [Any] ]()
                        if let snapData = docSnap?.documents {
                            var removedKeys = [Int]()
                            var updateKeys = [Int]()
                            for snap in snapData where snap.documentID == "week_\(trainingToDelete.week_uid)"{
                                let data = snap.data()
                                for key in data.keys {
                                    if key == "day_\(trainingToDelete.day_uid)" {
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
                            self.deletedTrainingPlanArray.removeAll()
                            var i = 0
                            updatedKey.forEach { key in
                                let json = JSON(dataValueKey[i].value)
                                for exerciseNumber in 0...json.count-1 {
                                    let newTrainingPlan = TrainingPlan(day_uid: key-1, week_uid: trainingToDelete.week_uid, exercise_uid: json[exerciseNumber]["exercise_uid"].intValue, exercise: json[exerciseNumber]["exercise"].stringValue, rounds: json[exerciseNumber]["rounds"].intValue, reps: json[exerciseNumber]["reps"].intValue, load: json[exerciseNumber]["load"].intValue, load_unit: json[exerciseNumber]["load_unit"].stringValue, videoURL: json[exerciseNumber]["videoURL"].stringValue, check: false)
                                    var newArray = [TrainingPlan]()
                                    newArray.append(newTrainingPlan)
                                    Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").updateData(["day_\(key-1)": [] ])
                                    Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").updateData(["day_\(key-1)": FieldValue.arrayUnion(dataValueKey[i].value) ])
                                }
                                i += 1
                                
                            }
                            self.trainingPlanArray.removeAll()
                            self.getTrainingData()
                            
                            
                            Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").updateData(["day_\(updatedKey.max()!)": FieldValue.delete()])
                        }
                    }
                }  else {
                    if trainingToDelete.day_uid == 1 {
                        numberOfWeeks -= 1
                        trainingPlanArray.remove(at: indexPath.section)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                        Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").delete()
                    } else {
                        numberOfDays["\(numberOfWeeks)"]?[0] -= 1
                        trainingPlanArray.remove(at: indexPath.section)
                        tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                        Firestore.firestore().collection("training_plan").document(self.user.uid).collection(Auth.auth().currentUser!.uid).document("week_\(trainingToDelete.week_uid)").updateData(["day_\(trainingToDelete.day_uid)": FieldValue.delete() ])
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
extension TrainingPlanViewController: TrainingPlanCellDelegate {
    func pickerViewDidEndEditing() {
        self.view.endEditing(true)
    }
    func trainingPlanCell(_ trainingPlanCell: TrainingPlanCell, newTrainingButtonPressed training: TrainingPlan) {
        self.dataCell.exerciseTextField.endEditing(true)
        self.dataCell.roundsTextField.endEditing(true)
        self.dataCell.repsTextField.endEditing(true)
        self.dataCell.loadTextField.endEditing(true)
        self.dataCell.loadTypeTextField.endEditing(true)
        self.dataCell.videoTextField.endEditing(true)
        
        guard let indexPath = self.tableView.indexPath(for: trainingPlanCell) else { return }
        let exercise = numberOfExercises["\(indexPath.section+1)"]
        let exerciseUID = exercise?.max() ?? 0
        
        var newArray = [TrainingPlan]()
        var trainingPlan = TrainingPlan(day_uid: 0, week_uid: 0, exercise_uid: 0, exercise: "", rounds: 0, reps: 0, load: 0, load_unit: "kg", videoURL: "", check: false)
        if indexPath.section > 5 && indexPath.section != 6 && (indexPath.section + 1) % 7 != 0 {
            trainingPlan = TrainingPlan(day_uid:  (indexPath.section + 1) % 7, week_uid: (indexPath.section / 7 ) + 1, exercise_uid: exerciseUID+1, exercise: "", rounds: 0, reps: 0, load: 0, load_unit: "kg", videoURL: "", check: false)
            TrainingPlan.setCurrent(trainingPlan)
        } else if (indexPath.section + 1) % 7 == 0 {
            trainingPlan = TrainingPlan(day_uid: (indexPath.section + 1) / ((indexPath.section + 1)/7 + (indexPath.section + 1)%7), week_uid: (indexPath.section + 1)/7 + (indexPath.section + 1)%7, exercise_uid: exerciseUID+1, exercise: "", rounds: 0, reps: 0, load: 0, load_unit: "kg", videoURL: "", check: false)
            TrainingPlan.setCurrent(trainingPlan)
        }
        else {
            trainingPlan = TrainingPlan(day_uid: indexPath.section + 1, week_uid: numberOfWeeks, exercise_uid: exerciseUID+1, exercise: "", rounds: 0, reps: 0, load: 0, load_unit: "kg", videoURL: "", check: false)
            TrainingPlan.setCurrent(trainingPlan)
        }
        self.service.updateDataToTrainingPlan(user_uid: user.uid, trainer_uid: Auth.auth().currentUser!.uid, week_uid: TrainingPlan.current.week_uid, day_uid: TrainingPlan.current.day_uid, exercise: TrainingPlan.current.exercise, exercise_uid: TrainingPlan.current.exercise_uid, rounds: TrainingPlan.current.rounds, reps: TrainingPlan.current.reps, load: TrainingPlan.current.load, load_unit: TrainingPlan.current.load_unit, videoURL: TrainingPlan.current.videoURL)
        newArray.append(trainingPlan)
        self.trainingPlanArray[indexPath.section].names[0].append(contentsOf: newArray)
        
        numberOfExercises["\(indexPath.section+1)"]?.append(TrainingPlan.current.exercise_uid)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func selectedTextField(_ trainingPlanCell: TrainingPlanCell, textField: UITextField) {
        guard let indexPath = self.tableView.indexPath(for: trainingPlanCell) else { return }
        dataCellNew = trainingPlanCell
        indexNew = indexPath
        let trainingPlan = trainingPlanArray[indexPath.section].names
        for plan in trainingPlan {
            dayUID = plan[indexPath.row].day_uid
            weekUID = plan[indexPath.row].week_uid
            exercise_uid = trainingPlanArray[indexPath.section].names[0][indexPath.row].exercise_uid
            if textField.tag == 0 {
                exercise = textField.text!
            } else {
                exercise = plan[indexPath.row].exercise
            }
            if textField.tag == 1 {
                rounds = Int(textField.text!)!
            } else {
                rounds = plan[indexPath.row].rounds
            }
            if textField.tag == 2 {
                reps = Int(textField.text!)!
            } else {
                reps = plan[indexPath.row].reps
            }
            if textField.tag == 3 {
                load = Int(textField.text!)!
            } else {
                load = plan[indexPath.row].load
            }
            if textField.tag == 4 {
                loadType = textField.text!
            } else {
                loadType = plan[indexPath.row].load_unit
            }
            if textField.tag == 5 {
                videoURL = textField.text!
            } else {
                videoURL = plan[indexPath.row].videoURL
            }
            check = false
        }
        let newTrainingPlan = TrainingPlan(day_uid: dayUID, week_uid: weekUID, exercise_uid: exercise_uid, exercise:  exercise, rounds: rounds, reps: reps, load: load, load_unit: loadType, videoURL: videoURL, check: check)
        TrainingPlan.setCurrent(newTrainingPlan)
        trainingPlanArray[indexPath.section].names[0][indexPath.row] = newTrainingPlan
        
        saveTrainingPlanArray.insert(trainingPlanArray[indexPath.section], at: newIndex)
        newIndex += 1
        save(data: dataCell)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}
extension TrainingPlanViewController: UITextFieldDelegate {
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
}
