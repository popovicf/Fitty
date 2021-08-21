//
//  TrainingReport.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase

protocol CloseViewTapped: AnyObject {
    func close(view: UIView)
}

class TrainingReport: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    let parentVC = FirstViewController()
    weak var delegate: CloseViewTapped?
    var trainingPlanArray = [ ExpandableNames(isExpanded: true, names: [[TrainingPlan]]() )]
    var userTrainingArray = [User : [ExpandableNames]]()
    let service = FirebaseService()
    var clients = [User]()
    var clientsInfo = [UserInfo]()
    var hasTheFunctionCalled : Bool = false {
        didSet{
            hasTheFunctionCalled = true
        }
    }
    var indexForDelete = IndexPath()
    var index = IndexPath()
    var group = DispatchGroup()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        tableView.delegate = self
        tableView.dataSource = self
        
        if !hasTheFunctionCalled{
            for client in clients{
                group.enter()
                getTrainingData(client: client)
               
            }
            self.group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        hasTheFunctionCalled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 30.0)
    }
    
    @IBAction func closeView(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.4, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
            self.delegate?.close(view: self)
        }) { (success:Bool) in
            self.removeFromSuperview()
        }
    }
    
    func getTrainingData(client: User){
        self.trainingPlanArray.removeAll()
        self.userTrainingArray.removeAll()
        self.service.getDataFromTrainingPlan(user_uid: client.uid, trainer_uid: Auth.auth().currentUser!.uid) { (saved_plan) in
            if !saved_plan.isEmpty {
                self.trainingPlanArray.removeAll()
                for plan in saved_plan {
                    self.trainingPlanArray.append(ExpandableNames(isExpanded: true, names: [plan]))
                }
                self.userTrainingArray.updateValue(self.trainingPlanArray, forKey: client)
                self.group.leave()
            }
        } daysArray: { (days) in } weeksArray: { (weeks) in } exercise_uids: { (exercise) in }
    }
}

extension TrainingReport: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = userTrainingArray.index(userTrainingArray.startIndex, offsetBy: section)
        for plan in userTrainingArray.values[index] where !plan.isExpanded{
            return 0
        }
        return userTrainingArray.values[index].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        userTrainingArray.values.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let index = userTrainingArray.index(userTrainingArray.startIndex, offsetBy: section)
        var indexPath = IndexPath()
        for counter in 0...(userTrainingArray.values[index].count - 1) {
            for row in userTrainingArray.values[index][counter].names.indices {
                indexPath = IndexPath(row: row, section: section)
            }
        }
        indexForDelete = indexPath
        let button = UIButton(type: .system)
        if userTrainingArray.values[index][indexPath.row].isExpanded {
            button.setTitle("\(userTrainingArray.keys[index].full_name)    -    Hide", for: .normal)
        } else {
            button.setTitle("\(userTrainingArray.keys[index].full_name)    -    Show", for: .normal)
        }
            
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        button.tag = section
        return button
    }
    
    @objc func handleExpandClose(button: UIButton){
        let section = button.tag
        let index = userTrainingArray.index(userTrainingArray.startIndex, offsetBy: section)
        var indexPath = IndexPath()
        var indexPaths = [IndexPath]()
        for row in userTrainingArray.values[index].indices {
            indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        let isExpanded = userTrainingArray.values[index][indexForDelete.row].isExpanded
        userTrainingArray.values[index][indexForDelete.row].isExpanded = !isExpanded
        
        if isExpanded {
            button.setTitle("\(userTrainingArray.keys[index].full_name)    -    Show", for: .normal)
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            button.setTitle("\(userTrainingArray.keys[index].full_name)    -    Hide", for: .normal)
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainingReportCell", for: indexPath) as! TrainingReportCell
        let indexSection = userTrainingArray.index(userTrainingArray.startIndex, offsetBy: indexPath.section)
        
        for plan in userTrainingArray.values[indexSection][indexPath.row].names
        {
            cell.weekDayLabel.text = "Week \(plan.first!.week_uid) - Day \(plan.first!.day_uid)"
            var counter = 0
            for p in plan {
                if p.check == true {
                    counter+=1
                }
            }
            if counter == plan.count {
                cell.checkButton.isHidden = false
            } else {
                cell.checkButton.isHidden = true
            }
        }
        return cell
    }
}
