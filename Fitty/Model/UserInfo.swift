//
//  UserInfo.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import Firebase

struct UserInfo: Equatable, Hashable {
    
    var uid: String = ""
    var bmiValue: String = ""
    var bmiAdvice: String = ""
    var height: String = ""
    var weight: String = ""
    var physicalCondition: String = ""
    var birthDate : Timestamp?
    var gender = ""
    var previousActivity = ""
    var injuries = ""
    var chronicDiseases = ""
    
    static var userInfoInstance = UserInfo(uid: "", bmiValue: "", bmiAdvice: "", height: "", weight: "", physicalCondition: "", birthDate: Timestamp(), gender: "", previousActivity: "", injuries: "", chronicDiseases: "")
    
    private static var _current: UserInfo?
    static var current: UserInfo {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }
    static func setCurrent(_ user: UserInfo) {
        _current = user
    }
    
    init() {
    }
    
    init(uid: String, bmiValue: String, bmiAdvice: String, height: String, weight: String, physicalCondition: String, birthDate: Timestamp, gender: String, previousActivity: String, injuries: String, chronicDiseases: String) {
        self.uid = uid
        self.bmiValue = bmiValue
        self.bmiAdvice = bmiAdvice
        self.height = height
        self.weight = weight
        self.physicalCondition = physicalCondition
        self.birthDate = birthDate
        self.gender = gender
        self.previousActivity = previousActivity
        self.injuries = injuries
        self.chronicDiseases = chronicDiseases
    }
    
    init?(snapshot: QuerySnapshot?) {
        if let snap = snapshot?.documents{
            for s in snap{
                let data = s.data()
                if let UID = data["uid"] as? String{
                    if UID == Auth.auth().currentUser?.uid {
                        self.uid = UID
                        self.bmiValue = data["bmi_value"] as! String
                        self.bmiAdvice = data["bmi_advice"] as! String
                        self.height = data["height"] as! String
                        self.weight = data["weight"] as! String
                        self.physicalCondition = data["physical_condition"] as! String
                        self.birthDate = data["birth_date"] as? Timestamp
                        self.gender = data["gender"] as! String
                        self.previousActivity = data["previous_activity"] as! String
                        self.injuries = data["injuries"] as! String
                        self.chronicDiseases = data["chronic_diseases"] as! String
                    }
                }
            }
        }
    }
    
    init?(allUsersInfoSnap: QuerySnapshot?) {
        if let snap = allUsersInfoSnap?.documents{
            for s in snap{
                let data = s.data()
                        self.uid = data["uid"] as? String ?? ""
                        self.bmiValue = data["bmi_value"] as? String ?? ""
                        self.bmiAdvice = data["bmi_advice"] as? String ?? ""
                        self.height = data["height"] as? String ?? ""
                        self.weight = data["weight"] as? String ?? ""
                        self.physicalCondition = data["physical_condition"] as? String ?? ""
                        self.birthDate = data["birth_date"] as? Timestamp ?? Timestamp()
                        self.gender = data["gender"] as? String ?? ""
                        self.previousActivity = data["previous_activity"] as? String ?? ""
                        self.injuries = data["injuries"] as? String ?? ""
                        self.chronicDiseases = data["chronic_diseases"] as? String ?? ""
            }
        }
    }
    
    mutating func setBMI(bmiValue: String, bmiAdvice: String) {
        self.bmiValue = bmiValue
        self.bmiAdvice = bmiAdvice
    }
    
    func getUserInfo() -> [String:Any] {
        return ["uid":uid, "bmiValue":bmiValue, "bmiAdvice":bmiAdvice, "height":height, "weight":weight, "physicalCondition":physicalCondition, "birthDate":birthDate ?? Timestamp(), "gender":gender, "previousActivity":previousActivity, "injuries":injuries, "chronicDiseases":chronicDiseases]
    }
    
}
