//
//  ShowPlanViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase
import youtube_ios_player_helper

protocol CheckReloadDelegate: AnyObject {
    func didChange()
}

class ShowPlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: CheckReloadDelegate?
    var trainingPlanArray = [ ExpandableNames(isExpanded: true, names: [[TrainingPlan]]() )]
    var saveTrainingPlanArray = [ ExpandableNames(isExpanded: true, names: [[TrainingPlan]]() )]
    var user = User()
    var numberOfWeeks = 0
    var numberOfDays: [String: [Int]] = [:]
    var numberOfExercises: [String: [Int]] = [:]
    let service = FirebaseService()
    var dataCell = ShowPlanCell()
    var indexForDelete = IndexPath()
    var index = IndexPath()
    var weekData = false
    let loader = Loader()
    var hasTheFunctionCalled : Bool = false {
        didSet{
            hasTheFunctionCalled = true
        }
    }
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
    var newIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 320
        self.trainingPlanArray.removeAll()
        self.saveTrainingPlanArray.removeAll()
        if weekData {
            getDataFromWeekTrainingPlan()
        } else {
            getTrainingData()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getTrainingData(){
        self.service.getDataFromTrainingPlan(user_uid: Auth.auth().currentUser!.uid, trainer_uid: self.user.uid) { (saved_plan) in
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
    
    func getDataFromWeekTrainingPlan(){
        self.service.getDataFromWeekTrainingPlan(user_uid: Auth.auth().currentUser!.uid, trainer_uid: self.user.uid, week_uid: "week_\(weekUID)", day_uid: "day_\(dayUID)") { (saved_plan) in
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
    
    func save(data : ShowPlanCell){
        var list = [[TrainingPlan]]()
        if saveTrainingPlanArray.count > 0 {
            for section in 0...saveTrainingPlanArray.count-1{
                list.append(contentsOf: self.saveTrainingPlanArray[section].names[0...saveTrainingPlanArray[section].names.count-1])
            }
        }
        for l in list {
            service.updateTrainingCheckToTrainingPlan(user_uid: Auth.auth().currentUser!.uid, trainer_uid: user.uid, plan: l)
        }
        list = []
        saveTrainingPlanArray = []
        newIndex = 0
    }
}
extension ShowPlanViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIWebViewDelegate, CheckButtonSelectionDelegate, YTPlayerViewDelegate {
    
    func didSelect(_ checkButton: UIButton, on cell: ShowPlanCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        let trainingPlan = trainingPlanArray[indexPath.section].names
        for plan in trainingPlan {
            dayUID = plan[indexPath.row].day_uid
            weekUID = plan[indexPath.row].week_uid
            exercise_uid = trainingPlanArray[indexPath.section].names[0][indexPath.row].exercise_uid
            exercise = plan[indexPath.row].exercise
            rounds = plan[indexPath.row].rounds
            reps = plan[indexPath.row].reps
            load = plan[indexPath.row].load
            loadType = plan[indexPath.row].load_unit
            videoURL = plan[indexPath.row].videoURL
            check = plan[indexPath.row].check
        }
        self.check.toggle()
        
        let newTrainingPlan = TrainingPlan(day_uid: dayUID, week_uid: weekUID, exercise_uid: exercise_uid, exercise:  exercise, rounds: rounds, reps: reps, load: load, load_unit: loadType, videoURL: videoURL, check: check)
        TrainingPlan.setCurrent(newTrainingPlan)
        trainingPlanArray[indexPath.section].names[0][indexPath.row] = newTrainingPlan
        
        saveTrainingPlanArray.insert(trainingPlanArray[indexPath.section], at: newIndex)
        newIndex += 1
        save(data: dataCell)
        self.tableView.reloadData()
        self.delegate?.didChange()
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.showPlanCell,  for: indexPath) as! ShowPlanCell
        index = indexPath
        dataCell = cell
        cell.delegate = self
        let trainingPlan = trainingPlanArray[indexPath.section].names
        for plan in trainingPlan {
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
            cell.youtubeVideo.delegate = self
            cell.youtubeVideo.tag = indexPath.row
            cell.exerciseTextField.text = plan[indexPath.row].exercise
            cell.exerciseTextField.isEnabled = false
            cell.roundsTextField.text = String(plan[indexPath.row].rounds)
            cell.roundsTextField.isEnabled = false
            cell.repsTextField.text = String(plan[indexPath.row].reps)
            cell.repsTextField.isEnabled = false
            cell.loadTextField.text = String(plan[indexPath.row].load)
            cell.loadTextField.isEnabled = false
            cell.loadTypeTextField.text = plan[indexPath.row].load_unit
            cell.loadTypeTextField.isEnabled = false
            var url = plan[indexPath.row].videoURL
            if url.contains("watch?v=") {
                url = plan[indexPath.row].videoURL.replacingOccurrences(of: "watch?v=", with: " ").split(separator: " ").last?.description ?? ""
            } else {
                url = plan[indexPath.row].videoURL.split(separator: "/").last?.description ?? ""
            }
            if !url.isEmpty {
                cell.youtubeVideo.isHidden = false
                tableView.rowHeight = 320
                cell.layer.bounds.size.height = 320
                cell.youtubeVideo.load(withVideoId: url, playerVars: ["playsinline": 1])
            }
            else {
                cell.youtubeVideo.isHidden = true
                tableView.rowHeight = 180
                cell.layer.bounds.size.height = 180
            }
            cell.check = plan[indexPath.row].check
            if plan[indexPath.row].check == true {
                DispatchQueue.main.async {
                cell.checkButton.imageView?.image = UIImage(systemName: "checkmark.circle.fill")
                cell.checkButton.imageView?.tintColor = .green
                cell.checkButton.imageView?.accessibilityIdentifier = "Filip"
                cell.checkButton.imageView?.image?.accessibilityIdentifier = "Popovic"
                }
            } else {
                DispatchQueue.main.async {
                cell.checkButton.imageView?.image = UIImage(systemName: "checkmark.circle")
                cell.checkButton.imageView?.tintColor = .lightGray
                }
            }
        }
        return cell
    }
    
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
