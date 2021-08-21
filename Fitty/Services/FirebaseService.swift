//
//  FirebaseService.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class FirebaseService: ObservableObject {
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    @Published var imageNew = UIImage()
    
    var dbData = User.userInstance
    var dbDataInfo = UserInfo.userInfoInstance
    
    init() {
        
    }
    
    func setDataToUserInfo(uidString: String, height: String, weight: String, bmiValue: String, bmiAdvice: String, physicalCondition: String, chronicDiseases: String, gender: String, injuries: String, previousActivity: String, date: Date) {
        self.db.collection("users_info").whereField("uid", isNotEqualTo: Auth.auth().currentUser!.uid).getDocuments { (query, error) in
            if let snapshot = query?.documents {
                for snap in snapshot {
                    let data = snap.data()
                    if let uid = data["uid"] as? String, let res = Auth.auth().currentUser?.uid {
                        self.db.collection("saved_ids").document("users_info").updateData(["uids" : FieldValue.arrayUnion([uid])])
                        self.db.collection("saved_ids").document("users_info").getDocument { (doc, error) in
                            if !(doc?.get("uids") as? [String])!.contains(res) {
                                self.db.collection("users_info").addDocument(data: ["uid" : uidString as Any, "height" : height, "weight" : weight, "bmi_value" : bmiValue, "bmi_advice" : bmiAdvice as Any, "physical_condition" : physicalCondition, "chronic_diseases" : chronicDiseases as Any, "gender" : gender as Any, "injuries" : injuries as Any, "previous_activity" : previousActivity as Any, "birth_date" : date])
                                self.db.collection("saved_ids").document("users_info").updateData(["uids" : FieldValue.arrayUnion([res])])
                            } else {
                                self.db.collection("users_info").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (query, error) in
                                    if let snapshot = query?.documents{
                                        for snap in snapshot {
                                            let documentID = snap.documentID
                                            self.db.collection("users_info").document(documentID).updateData(["uid" : uidString as Any, "height" : height as Any, "weight" : weight as Any, "bmi_value" : bmiValue as Any, "bmi_advice" : bmiAdvice as Any])
                                        }
                                    }
                                }
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    
    func setDataToUserInfoAdditional(physicalCondition: String, chronicDiseases: String, gender: String, injuries: String, previousActivity: String, date: Date) {
        self.db.collection("users_info").whereField("uid", isNotEqualTo: Auth.auth().currentUser!.uid).getDocuments { (query, error) in
            if let snapshot = query?.documents {
                for snap in snapshot {
                    let data = snap.data()
                    if let uid = data["uid"] as? String, let res = Auth.auth().currentUser?.uid {
                        self.db.collection("saved_ids").document("users_info").updateData(["uids" : FieldValue.arrayUnion([uid])])
                        self.db.collection("saved_ids").document("users_info").getDocument { (doc, error) in
                            if !(doc?.get("uids") as? [String])!.contains(res) {
                                self.db.collection("users_info").addDocument(data: ["physical_condition" : physicalCondition, "chronic_diseases" : chronicDiseases, "gender" : gender, "injuries" : injuries, "previous_activity" : previousActivity, "birth_date" : date])
                                self.db.collection("saved_ids").document("users_info").updateData(["uids" : FieldValue.arrayUnion([res])])
                            } else {
                                self.db.collection("users_info").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (query, error) in
                                    if let snapshot = query?.documents{
                                        for snap in snapshot {
                                            let documentID = snap.documentID
                                            self.db.collection("users_info").document(documentID).updateData(["physical_condition" : physicalCondition, "chronic_diseases" : chronicDiseases, "gender" : gender, "injuries" : injuries, "previous_activity" : previousActivity, "birth_date" : date])
                                        }
                                    }
                                }
                            }
                        }
                        break
                    }
                }
            }
        }
    }
    
    func setDataToUser(fullName: String, email: String, profilePicture: String) {
        self.db.collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (query, error) in
            if let snapshot = query?.documents{
                for snap in snapshot {
                    let documentID = snap.documentID
                    self.db.collection("users").document(documentID).updateData(["full_name" : fullName, "email" : email, "profile_picture" : profilePicture])
                }
            }
        }
    }
    
    func setDataToStorage(image: UIImage, folder: String, fileExtension: String) {
        let storageRef = storage.reference()
        let fileName = Auth.auth().currentUser?.uid
        let uploadData = image.pngData()
        storageRef.child(folder).child(fileName!).child("\(fileName!)"+fileExtension).putData(uploadData!, metadata: nil) { (metadata, error) in
            if let err = error {
                print(err)
            }
        }.resume()
    }
    
    func getDataFromStorage(folder: String, fileExtension: String) {
        let storageRef = Storage.storage().reference()
        let fileName = Auth.auth().currentUser?.uid ?? ""
        storageRef.child(folder).child(fileName).child("\(fileName)"+fileExtension).getData(maxSize: .max) { (data, error) in
            guard let data = data, error == nil else {return}
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageNew = image
                }
            }
        }.resume()
    }
    
    func getDataFromCollection(collection: String, completionUser: @escaping (User?) -> Void,  completionUserInfo: @escaping (UserInfo?) -> Void) {
        Firestore.firestore().collection(collection).getDocuments { (querySnapshot, error) in
            if let e = error {
                print(e)
            } else {
                switch collection {
                case "users_info":
                    if let userInfo = UserInfo(snapshot: querySnapshot){
                        self.dbDataInfo = userInfo
                        completionUserInfo(userInfo)
                    }
                case "users":
                    if let user = User(snapshot: querySnapshot){
                        self.dbData = user
                        completionUser(user)
                    }
                default:
                    break
                }
            }
        }
    }
    
    func getUserFromID(collection: String, ID: String, completionUser: @escaping (User?) -> Void, completionUserInfo: @escaping (UserInfo?) -> Void) {
        Firestore.firestore().collection(collection).whereField("uid", isEqualTo: ID).getDocuments { (querySnap, error) in
            if let user = User(allUsersSnap: querySnap) {
                completionUser(user)
            }
            if let userInfo = UserInfo(allUsersInfoSnap: querySnap) {
                completionUserInfo(userInfo)
            }
        }
    }
    
    func uploadImage(imageData: Data, path: String, fileExtension: String, completion: @escaping (String) -> ()){
        
        let storage = Storage.storage().reference()
        let uid = Auth.auth().currentUser!.uid
        
        storage.child(path).child(uid).child("\(uid)"+fileExtension).putData(imageData, metadata: nil) { (_, err) in
            if err != nil {
                completion("")
                return
            }
            
            storage.child(path).child(uid).child("\(uid)"+fileExtension).downloadURL { (url, err) in
                if err != nil {
                    completion("")
                    return
                }
                completion("\(url!)")
            }
        }
    }
    
    func setDataToTrainingPlan(user_uid: String, trainer_uid: String, week_uid: Int, day_uid: Int, exercise: String, exercise_uid: Int, rounds: Int, reps: Int, load: Int, load_unit: String, videoURL: String) {
        self.db.collection("training_plan").document(user_uid).collection(trainer_uid).document("week_\(week_uid)").setData(["day_\(day_uid)" : FieldValue.arrayUnion([ ["exercise": exercise, "exercise_uid": exercise_uid, "load": load, "load_unit": load_unit, "rounds": rounds, "reps": reps, "videoURL": videoURL] ]) ])
    }
    
    func setDataToNutritionPlan(user_uid: String, trainer_uid: String, week_uid: Int, day_uid: Int, meal_name: String, nutrition_uid: Int, nutrition_plan: String, check: Bool) {
        self.db.collection("nutrition_plan").document(user_uid).collection(trainer_uid).document("week_\(week_uid)").setData(["day_\(day_uid)" : FieldValue.arrayUnion([ ["meal_name": meal_name, "nutrition_uid": nutrition_uid, "nutrition_plan": nutrition_plan, "check": check] ]) ])
    }
    
    func updateDataToTrainingPlan(user_uid: String, trainer_uid: String, week_uid: Int, day_uid: Int, exercise: String, exercise_uid: Int, rounds: Int, reps: Int, load: Int, load_unit: String, videoURL: String) {
        self.db.collection("training_plan").document(user_uid).collection(trainer_uid).document("week_\(week_uid)").updateData(["day_\(day_uid)" : FieldValue.arrayUnion([ ["exercise": exercise, "exercise_uid": exercise_uid, "load": load, "load_unit": load_unit, "rounds": rounds, "reps": reps, "videoURL": videoURL] ]) ])
    }
    
    func updateDataToNutritionPlan(user_uid: String, trainer_uid: String, week_uid: Int, day_uid: Int, meal_name: String, nutrition_uid: Int, nutrition_plan: String, check: Bool) {
        self.db.collection("nutrition_plan").document(user_uid).collection(trainer_uid).document("week_\(week_uid)").updateData(["day_\(day_uid)" : FieldValue.arrayUnion([ ["meal_name": meal_name, "nutrition_uid": nutrition_uid, "nutrition_plan": nutrition_plan, "check": check] ]) ])
    }
    
    func getDataFromTrainingPlan(user_uid: String, trainer_uid: String, completion: @escaping ([[TrainingPlan]]) -> (), daysArray: @escaping ([String: [Int]]) -> (), weeksArray: @escaping ([Int]) -> (), exercise_uids: @escaping ([String: [Int]]) -> ()){
        self.db.collection("training_plan").document(user_uid).collection(trainer_uid).getDocuments { (querySnapshot, error) in
             _ = TrainingPlan(snapshot: querySnapshot, completion: { (trainingPlanArray) in
                completion(trainingPlanArray)
             }, days: { (days) in
                daysArray(days)
             }, exercise_uids: { (exercise) in
                exercise_uids(exercise)
             }, weeks: { (weeks) in
                weeksArray(weeks)
             } )
        }
    }
    
    func getDataFromNutritionPlan(user_uid: String, trainer_uid: String, completion: @escaping ([[NutritionPlan]]) -> (), daysArray: @escaping ([String: [Int]]) -> (), weeksArray: @escaping ([Int]) -> (), nutrition_uids: @escaping ([String: [Int]]) -> ()){
        self.db.collection("nutrition_plan").document(user_uid).collection(trainer_uid).getDocuments { (querySnapshot, error) in
             _ = NutritionPlan(snapshot: querySnapshot, completion: { (nutritionPlanArray) in
                completion(nutritionPlanArray)
             }, days: { (days) in
                daysArray(days)
             }, nutrition_uids: { (exercise) in
                nutrition_uids(exercise)
             }, weeks: { (weeks) in
                weeksArray(weeks)
             } )
        }
    }
    
    func getDataFromWeekTrainingPlan(user_uid: String, trainer_uid: String, week_uid: String, day_uid: String, completion: @escaping ([[TrainingPlan]]) -> (), daysArray: @escaping ([String: [Int]]) -> (), weeksArray: @escaping ([Int]) -> (), exercise_uids: @escaping ([String: [Int]]) -> ()){
        self.db.collection("training_plan").document(user_uid).collection(trainer_uid).document(week_uid).getDocument { (querySnapshot, error) in
            _ = TrainingPlan(snapshot: querySnapshot, day_uid: day_uid, completion: { (trainingPlanArray) in
                completion(trainingPlanArray)
             }, days: { (days) in
                daysArray(days)
             }, exercise_uids: { (exercise) in
                exercise_uids(exercise)
             }, weeks: { (weeks) in
                weeksArray(weeks)
             } )
        }
    }
    
    func getDataFromWeekNutritionPlan(user_uid: String, trainer_uid: String, week_uid: String, day_uid: String, completion: @escaping ([[NutritionPlan]]) -> (), daysArray: @escaping ([String: [Int]]) -> (), weeksArray: @escaping ([Int]) -> (), nutrition_uids: @escaping ([String: [Int]]) -> ()){
        self.db.collection("nutrition_plan").document(user_uid).collection(trainer_uid).document(week_uid).getDocument { (querySnapshot, error) in
            _ = NutritionPlan(snapshot: querySnapshot, day_uid: day_uid, completion: { (nutritionPlanArray) in
                completion(nutritionPlanArray)
             }, days: { (days) in
                daysArray(days)
             }, nutrition_uids: { (nutrition) in
                nutrition_uids(nutrition)
             }, weeks: { (weeks) in
                weeksArray(weeks)
             } )
        }
    }
    
    func getUserTrainingPlan(trainer_uid: String, completion: @escaping ([[TrainingPlan]]) -> (), daysArray: @escaping ([String: [Int]]) -> (), weeksArray: @escaping ([Int]) -> (), exercise_uids: @escaping ([String: [Int]]) -> ()){
        self.db.collection("training_plan").document(Auth.auth().currentUser!.uid).collection(trainer_uid).getDocuments { (querySnapshot, error) in
            _ = TrainingPlan(snapshot: querySnapshot, completion: { (trainingPlanArray) in
               completion(trainingPlanArray)
            }, days: { (days) in
               daysArray(days)
            }, exercise_uids: { (exercise) in
               exercise_uids(exercise)
            }, weeks: { (weeks) in
               weeksArray(weeks)
            } )
        }
    }
    
    func getUserNutritionPlan(trainer_uid: String, completion: @escaping ([[NutritionPlan]]) -> (), daysArray: @escaping ([String: [Int]]) -> (), weeksArray: @escaping ([Int]) -> (), nutrition_uids: @escaping ([String: [Int]]) -> ()){
        self.db.collection("nutrition_plan").document(Auth.auth().currentUser!.uid).collection(trainer_uid).getDocuments { (querySnapshot, error) in
            _ = NutritionPlan(snapshot: querySnapshot, completion: { (nutritionPlanArray) in
               completion(nutritionPlanArray)
            }, days: { (days) in
               daysArray(days)
            }, nutrition_uids: { (nutrition) in
                nutrition_uids(nutrition)
            }, weeks: { (weeks) in
               weeksArray(weeks)
            } )
        }
    }
    
    func saveAllDataToTrainingPlan(user_uid: String, trainer_uid: String, plan: [TrainingPlan]){
        var array = [Any]()
        var week_uid = 0
        var day_uid = 0
        var exercise = ""
        var exercise_uid = 0
        var load = 0
        var load_unit = ""
        var rounds = 0
        var reps = 0
        var video = ""
        var check = false
        
        for p in plan {
            week_uid = p.week_uid
            day_uid = p.day_uid
            exercise = p.exercise
            exercise_uid = p.exercise_uid
            load = p.load
            load_unit = p.load_unit
            rounds = p.rounds
            reps = p.reps
            video = p.videoURL
            check = p.check
            let newTrainingPlan: [String: Any] = ["exercise_uid": exercise_uid, "exercise": exercise, "rounds": rounds, "reps": reps, "load": load, "load_unit": load_unit, "videoURL": video, "check": check]
            array.append(newTrainingPlan)
        }
        
        self.db.collection("training_plan").document(user_uid).collection(Auth.auth().currentUser!.uid).document("week_\(week_uid)").updateData(["day_\(day_uid)": [] ])
        
        self.db.collection("training_plan").document(user_uid).collection(trainer_uid).document("week_\(week_uid)").updateData(["day_\(day_uid)" : FieldValue.arrayUnion( array ) ])
    }
    
    func saveAllDataToNutritionPlan(user_uid: String, trainer_uid: String, plan: [NutritionPlan]){
        var array = [Any]()
        var week_uid = 0
        var day_uid = 0
        var meal_name = ""
        var nutrition_uid = 0
        var nutrition_plan = ""
        var check = false
        
        for p in plan {
            week_uid = p.week_uid
            day_uid = p.day_uid
            meal_name = p.meal_name
            nutrition_uid = p.nutrition_uid
            nutrition_plan = p.nutrition_plan
            check = p.check
            let newNutritionPlan: [String: Any] = ["meal_name": meal_name, "nutrition_uid": nutrition_uid, "nutrition_plan": nutrition_plan, "check": check]
            array.append(newNutritionPlan)
        }
        
        self.db.collection("nutrition_plan").document(user_uid).collection(Auth.auth().currentUser!.uid).document("week_\(week_uid)").updateData(["day_\(day_uid)": [] ])
        
        self.db.collection("nutrition_plan").document(user_uid).collection(trainer_uid).document("week_\(week_uid)").updateData(["day_\(day_uid)" : FieldValue.arrayUnion( array ) ])
    }
    
    func setAllDataToTrainingPlan(user_uid: String, trainer_uid: String, plan: [TrainingPlan]){
        for p in plan {
            self.db.collection("training_plan").document(user_uid).collection(trainer_uid).document("week_\(p.week_uid)").setData(["day_\(p.day_uid)" : ["exercise": p.exercise, "load": p.load, "load_unit": p.load_unit, "rounds": p.rounds, "reps": p.reps, "videoURL": p.videoURL] ])
        }
    }
    
    func updateTrainingCheckToTrainingPlan(user_uid: String, trainer_uid: String, plan: [TrainingPlan]) {
        
        var array = [Any]()
        var week_uid = 0
        var day_uid = 0
        var exercise = ""
        var exercise_uid = 0
        var load = 0
        var load_unit = ""
        var rounds = 0
        var reps = 0
        var video = ""
        var check = false
        
        for p in plan {
            week_uid = p.week_uid
            day_uid = p.day_uid
            exercise = p.exercise
            exercise_uid = p.exercise_uid
            load = p.load
            load_unit = p.load_unit
            rounds = p.rounds
            reps = p.reps
            video = p.videoURL
            check = p.check
            let newTrainingPlan: [String: Any] = ["exercise_uid": exercise_uid, "exercise": exercise, "rounds": rounds, "reps": reps, "load": load, "load_unit": load_unit, "videoURL": video, "check": check]
            array.append(newTrainingPlan)
        }
      
        self.db.collection("training_plan").document(user_uid).collection(trainer_uid).document("week_\(week_uid)").updateData(["day_\(day_uid)": [] ])
        
        self.db.collection("training_plan").document(user_uid).collection(trainer_uid).document("week_\(week_uid)").updateData(["day_\(day_uid)" : FieldValue.arrayUnion( array ) ])
    }
    
}
