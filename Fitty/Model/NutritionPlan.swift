//
//  NutritionPlan.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import Firebase

struct NutritionPlan: Equatable, Hashable {
    
    var week_uid: Int = 0
    var day_uid: Int = 0
    var meal_name: String = ""
    var nutrition_plan: String = ""
    var nutrition_uid: Int = 0
    var check: Bool = false
    static var nutritionPlanInstance = NutritionPlan(week_uid: 0, day_uid: 0, meal_name: "", nutrition_plan: "", nutrition_uid: 0, check: false)
    
    private static var _current: NutritionPlan?
    static var current: NutritionPlan {
        guard let currentPlan = _current else {
            fatalError("Error: current training plan doesn't exist")
        }
        return currentPlan
    }
    static func setCurrent(_ nutritionPlan: NutritionPlan) {
        _current = nutritionPlan
    }
    
    init(week_uid: Int, day_uid: Int, meal_name: String, nutrition_plan: String, nutrition_uid: Int, check: Bool) {
        self.week_uid = week_uid
        self.day_uid = day_uid
        self.meal_name = meal_name
        self.nutrition_plan = nutrition_plan
        self.nutrition_uid = nutrition_uid
        self.check = check
    }
    
    init?(snapshot: QuerySnapshot?, completion: @escaping ([[NutritionPlan]]) -> (), days: @escaping ([String: [Int]]) -> (), nutrition_uids: @escaping ([String: [Int]]) -> (), weeks: @escaping ([Int]) -> ()) {
        var weeksArray = [Int]()
        var daysArray: [String: [Int]] = [:]
        var nutrition_uidsArray: [String: [Int]] = [:]
        if let snapshot = snapshot?.documents {
            var finalArray = [[NutritionPlan]]()
            for snap in snapshot {
                var sortedArray = [NutritionPlan]()
                let data = snap.data()
                let days = data.keys.sorted()
                for day in days {
                    self.day_uid = Int(day.split(separator: "_")[1])!
                    self.week_uid = Int(snap.documentID.split(separator: "_")[1])!
                    let day_data = data["day_\(day_uid)"] as! [[String:Any]]
                    var array = [NutritionPlan]()
                    var daysArr = [Int]()
                    var nutritionArr = [Int]()
                    for day  in day_data{
                        for d in day where d.key == "meal_name"{
                            self.meal_name = d.value as! String
                        }
                        for d in day where d.key == "nutrition_plan"{
                            self.nutrition_plan = d.value as! String
                        }
                        for d in day where d.key == "nutrition_uid"{
                            self.nutrition_uid = d.value as! Int
                        }
                        for d in day where d.key == "check"{
                            self.check = d.value as! Bool
                        }
                        array.append(NutritionPlan(week_uid: self.week_uid, day_uid: self.day_uid, meal_name: self.meal_name, nutrition_plan: self.nutrition_plan, nutrition_uid: self.nutrition_uid, check: self.check))
                        weeksArray.append(self.week_uid)
                        daysArr.append(self.day_uid)
                        nutritionArr.append(self.nutrition_uid)
                        
                        sortedArray = array.sorted { (trPlan1, trPlan2) -> Bool in
                            trPlan1.day_uid < trPlan2.day_uid
                        }
                        daysArray.updateValue(Array(Set(daysArr)), forKey: "\(self.week_uid)")
                        nutrition_uidsArray.updateValue(nutritionArr, forKey: "\(self.day_uid + ((self.week_uid-1) * 7))")
                    }
                    finalArray.append(sortedArray)
                }
            }
            completion(finalArray)
            weeks(weeksArray)
            days(daysArray)
            nutrition_uids(nutrition_uidsArray)
        }
    }
    
    init?(snapshot: DocumentSnapshot?, day_uid: String, completion: @escaping ([[NutritionPlan]]) -> (), days: @escaping ([String: [Int]]) -> (), nutrition_uids: @escaping ([String: [Int]]) -> (), weeks: @escaping ([Int]) -> ()) {
        var weeksArray = [Int]()
        var daysArray: [String: [Int]] = [:]
        var nutrition_uidsArray: [String: [Int]] = [:]
        
        var finalArray = [[NutritionPlan]]()
        var sortedArray = [NutritionPlan]()
        if let data = snapshot?.data() {
            let days = data.keys.sorted()
            for day in days {
                self.day_uid = Int(day.split(separator: "_")[1])!
                if day_uid == "day_\(self.day_uid)" {
                    self.week_uid = Int(snapshot!.documentID.split(separator: "_")[1])!
                    let day_data = data["day_\(self.day_uid)"] as! [[String:Any]]
                    
                    var array = [NutritionPlan]()
                    var daysArr = [Int]()
                    var nutritionArr = [Int]()
                    for day  in day_data{
                        for d in day where d.key == "meal_name"{
                            self.meal_name = d.value as! String
                        }
                        for d in day where d.key == "nutrition_plan"{
                            self.nutrition_plan = d.value as! String
                        }
                        for d in day where d.key == "nutrition_uid"{
                            self.nutrition_uid = d.value as! Int
                        }
                        for d in day where d.key == "check"{
                            self.check = d.value as! Bool
                        }
                        array.append(NutritionPlan(week_uid: self.week_uid, day_uid: self.day_uid, meal_name: self.meal_name, nutrition_plan: self.nutrition_plan, nutrition_uid: self.nutrition_uid, check: self.check))
                        weeksArray.append(self.week_uid)
                        daysArr.append(self.day_uid)
                        nutritionArr.append(self.nutrition_uid)
                        
                        sortedArray = array.sorted { (trPlan1, trPlan2) -> Bool in
                            trPlan1.day_uid < trPlan2.day_uid
                        }
                        daysArray.updateValue(Array(Set(daysArr)), forKey: "\(self.week_uid)")
                        nutrition_uidsArray.updateValue(nutritionArr, forKey: "\(self.day_uid + ((self.week_uid-1) * 7))")
                    }
                    finalArray.append(sortedArray)
                }
            }
        }
        completion(finalArray)
        weeks(weeksArray)
        days(daysArray)
        nutrition_uids(nutrition_uidsArray)
    }
}
