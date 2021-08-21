//
//  TrainingPlan.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import Firebase

struct TrainingPlan: Equatable, Hashable {
    
    var week_uid: Int = 0
    var day_uid: Int = 0
    var exercise_uid: Int = 0
    var exercise: String = ""
    var rounds: Int = 0
    var reps: Int = 0
    var load: Int = 0
    var load_unit: String = ""
    var videoURL: String = ""
    var check = false
    static var trainingPlanInstance = TrainingPlan(day_uid: 0, week_uid: 0, exercise_uid: 0, exercise: "", rounds: 0, reps: 0, load: 0, load_unit: "", videoURL: "", check: false)
    
    private static var _current: TrainingPlan?
    static var current: TrainingPlan {
        guard let currentUser = _current else {
            fatalError("Error: current training plan doesn't exist")
        }
        return currentUser
    }
    static func setCurrent(_ trainingPlan: TrainingPlan) {
        _current = trainingPlan
    }
    
    init(day_uid: Int, week_uid: Int, exercise_uid: Int, exercise: String, rounds: Int, reps: Int, load: Int, load_unit: String, videoURL: String, check: Bool) {
        self.day_uid = day_uid
        self.week_uid = week_uid
        self.exercise_uid = exercise_uid
        self.exercise = exercise
        self.rounds = rounds
        self.reps = reps
        self.load = load
        self.load_unit = load_unit
        self.videoURL = videoURL
        self.check = check
    }
    
    init?(snapshot: QuerySnapshot?, completion: @escaping ([[TrainingPlan]]) -> (), days: @escaping ([String: [Int]]) -> (), exercise_uids: @escaping ([String: [Int]]) -> (), weeks: @escaping ([Int]) -> ()) {
        var weeksArray = [Int]()
        var daysArray: [String: [Int]] = [:]
        var exercise_uidsArray: [String: [Int]] = [:]
        if let snapshot = snapshot?.documents {
            var finalArray = [[TrainingPlan]]()
            for snap in snapshot {
                var sortedArray = [TrainingPlan]()
                let data = snap.data()
                let days = data.keys.sorted()
                for day in days {
                    self.day_uid = Int(day.split(separator: "_")[1])!
                    self.week_uid = Int(snap.documentID.split(separator: "_")[1])!
                    let day_data = data["day_\(day_uid)"] as! [[String:Any]]
                    var array = [TrainingPlan]()
                    var daysArr = [Int]()
                    var exerciseArr = [Int]()
                    for day  in day_data{
                        for d in day where d.key == "exercise_uid"{
                            self.exercise_uid = d.value as! Int
                        }
                        for d in day where d.key == "exercise"{
                            self.exercise = d.value as! String
                        }
                        for d in day where d.key == "load"{
                            self.load = d.value as! Int
                        }
                        for d in day where d.key == "load_unit"{
                            self.load_unit = d.value as! String
                        }
                        for d in day where d.key == "reps"{
                            self.reps = d.value as! Int
                        }
                        for d in day where d.key == "rounds"{
                            self.rounds = d.value as! Int
                        }
                        for d in day where d.key == "videoURL"{
                            self.videoURL = d.value as! String
                        }
                        for d in day where d.key == "videoURL"{
                            self.videoURL = d.value as! String
                        }
                        for d in day where d.key == "check"{
                            self.check = d.value as! Bool
                        }
                        array.append(TrainingPlan(day_uid: self.day_uid, week_uid: self.week_uid, exercise_uid: self.exercise_uid, exercise: self.exercise, rounds: self.rounds, reps: self.reps, load: self.load, load_unit: self.load_unit, videoURL: self.videoURL, check: self.check))
                        weeksArray.append(self.week_uid)
                        daysArr.append(self.day_uid)
                        exerciseArr.append(self.exercise_uid)
                        
                        sortedArray = array.sorted { (trPlan1, trPlan2) -> Bool in
                            trPlan1.day_uid < trPlan2.day_uid
                        }
                        daysArray.updateValue(Array(Set(daysArr)), forKey: "\(self.week_uid)")
                        exercise_uidsArray.updateValue(exerciseArr, forKey: "\(self.day_uid + ((self.week_uid-1) * 7))")
                    }
                    finalArray.append(sortedArray)
                }
            }
            completion(finalArray)
            weeks(weeksArray)
            days(daysArray)
            exercise_uids(exercise_uidsArray)
        }
    }
    
    init?(snapshot: DocumentSnapshot?, day_uid: String, completion: @escaping ([[TrainingPlan]]) -> (), days: @escaping ([String: [Int]]) -> (), exercise_uids: @escaping ([String: [Int]]) -> (), weeks: @escaping ([Int]) -> ()) {
        var weeksArray = [Int]()
        var daysArray: [String: [Int]] = [:]
        var exercise_uidsArray: [String: [Int]] = [:]
        
        var finalArray = [[TrainingPlan]]()
        var sortedArray = [TrainingPlan]()
        if let data = snapshot?.data() {
            let days = data.keys.sorted()
            for day in days {
                self.day_uid = Int(day.split(separator: "_")[1])!
                if day_uid == "day_\(self.day_uid)" {
                    self.week_uid = Int(snapshot!.documentID.split(separator: "_")[1])!
                    let day_data = data["day_\(self.day_uid)"] as! [[String:Any]]
                    
                    var array = [TrainingPlan]()
                    var daysArr = [Int]()
                    var exerciseArr = [Int]()
                    for day  in day_data{
                        for d in day where d.key == "exercise_uid"{
                            self.exercise_uid = d.value as! Int
                        }
                        for d in day where d.key == "exercise"{
                            self.exercise = d.value as! String
                        }
                        for d in day where d.key == "load"{
                            self.load = d.value as! Int
                        }
                        for d in day where d.key == "load_unit"{
                            self.load_unit = d.value as! String
                        }
                        for d in day where d.key == "reps"{
                            self.reps = d.value as! Int
                        }
                        for d in day where d.key == "rounds"{
                            self.rounds = d.value as! Int
                        }
                        for d in day where d.key == "videoURL"{
                            self.videoURL = d.value as! String
                        }
                        for d in day where d.key == "check"{
                            self.check = d.value as! Bool
                        }
                        array.append(TrainingPlan(day_uid: self.day_uid, week_uid: self.week_uid, exercise_uid: self.exercise_uid, exercise: self.exercise, rounds: self.rounds, reps: self.reps, load: self.load, load_unit: self.load_unit, videoURL: self.videoURL, check: self.check))
                        weeksArray.append(self.week_uid)
                        daysArr.append(self.day_uid)
                        exerciseArr.append(self.exercise_uid)
                        
                        sortedArray = array.sorted { (trPlan1, trPlan2) -> Bool in
                            trPlan1.day_uid < trPlan2.day_uid
                        }
                        daysArray.updateValue(Array(Set(daysArr)), forKey: "\(self.week_uid)")
                        exercise_uidsArray.updateValue(exerciseArr, forKey: "\(self.day_uid + ((self.week_uid-1) * 7))")
                    }
                    finalArray.append(sortedArray)
                }
            }
        }
        completion(finalArray)
        weeks(weeksArray)
        days(daysArray)
        exercise_uids(exercise_uidsArray)
    }
}
