//
//  ShowNutritionPlanViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase


class ShowNutritionPlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var nutritionPlanArray = [ ExpandableNutritionPlan(isExpanded: true, names: [[NutritionPlan]]() )]
    var saveNutritionPlanArray = [ ExpandableNutritionPlan(isExpanded: true, names: [[NutritionPlan]]() )]
    var user = User()
    var numberOfWeeks = 0
    var numberOfDays: [String: [Int]] = [:]
    var numberOfExercises: [String: [Int]] = [:]
    let service = FirebaseService()
    var dataCell = ShowNutritionPlanCell()
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
        tableView.rowHeight = 180
        self.nutritionPlanArray.removeAll()
        self.saveNutritionPlanArray.removeAll()
        if weekData {
            getDataFromWeekNutritionPlan()
        } else {
            getNutritionData()
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getNutritionData(){
        self.service.getDataFromNutritionPlan(user_uid: Auth.auth().currentUser!.uid, trainer_uid: self.user.uid) { (saved_plan) in
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
        } nutrition_uids: { (exercise) in
            self.numberOfExercises = exercise
        }
    }
    
    func getDataFromWeekNutritionPlan(){
        self.service.getDataFromWeekNutritionPlan(user_uid: Auth.auth().currentUser!.uid, trainer_uid: self.user.uid, week_uid: "week_\(weekUID)", day_uid: "day_\(dayUID)") { (saved_plan) in
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
        } nutrition_uids: { (exercise) in
            self.numberOfExercises = exercise
        }
    }
    
    func save(data : ShowNutritionPlanCell){
        var list = [[NutritionPlan]]()
        if saveNutritionPlanArray.count > 0 {
            for section in 0...saveNutritionPlanArray.count-1{
                list.append(contentsOf: self.saveNutritionPlanArray[section].names[0...saveNutritionPlanArray[section].names.count-1])
            }
        }
        list = []
        saveNutritionPlanArray = []
        newIndex = 0
    }
}
extension ShowNutritionPlanViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.showNutritionPlanCell,  for: indexPath) as! ShowNutritionPlanCell
        index = indexPath
        dataCell = cell
        let nutritionPlan = nutritionPlanArray[indexPath.section].names
        for plan in nutritionPlan {
            cell.mealNameLabel.delegate = self
            cell.mealNameLabel.tag = indexPath.row
            cell.nutritionPlanTextView.delegate = self
            cell.nutritionPlanTextView.tag = indexPath.row
            cell.mealNameLabel.isEnabled = false
            cell.nutritionPlanTextView.isEditable = false
            cell.mealNameLabel.text = plan[indexPath.row].meal_name
            if plan[indexPath.row].nutrition_plan == "Create daily nutrition plan" {
                cell.nutritionPlanTextView.text = "No plan"
            } else {
                cell.nutritionPlanTextView.text = plan[indexPath.row].nutrition_plan
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

