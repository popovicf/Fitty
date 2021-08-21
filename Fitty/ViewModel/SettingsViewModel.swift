//
//  SettingsViewModel.swift
//  Fitty
//
//  Created by Filip Popovic
//

import SwiftUI
import Firebase
import SDWebImage
import FBSDKLoginKit

class SettingsViewModel: ObservableObject{
    
    @Published var user = User(uid: "", full_name: "", email: "", profile_picture: "", admin: false)
    @Published var userInfo = UserInfo(uid: "", bmiValue: "", bmiAdvice: "", height: "", weight: "", physicalCondition: "", birthDate: Timestamp(), gender: "", previousActivity: "", injuries: "", chronicDiseases: "")
    @AppStorage("current_status") var status = true
    @Published var picker = false
    @Published var img_data = Data(count: 0)
    @Published var isLoading = false
    @Published var height = ""
    @Published var weight = ""
    @Published var color: Color = .white
    var bmiCalculator = BMICalculator()
    let db = Firestore.firestore()
    let uid = Auth.auth().currentUser?.uid
    let firbaseService = FirebaseService()
    let defaults = UserDefaults.standard
    @Published var error = ""
    
    init() {
        user = firbaseService.dbData
        userInfo = firbaseService.dbDataInfo
        fetchUser(collection: "users")
        fetchUser(collection: "users_info")
    }
    
    func fetchUser(collection: String) {
        db.collection(collection).getDocuments { (querySnapshot, error) in
            switch collection {
            case "users_info":
                if let userInfo = UserInfo(snapshot: querySnapshot){
                    let uid = userInfo.uid
                    let bmiValue = userInfo.bmiValue
                    let bmiAdvice = userInfo.bmiAdvice
                    let height = userInfo.height
                    let weight = userInfo.weight
                    let birthDate = userInfo.birthDate ?? Timestamp()
                    let gender = userInfo.gender
                    let physicalCondition = userInfo.physicalCondition
                    let previousActivity = userInfo.previousActivity
                    let injuries = userInfo.injuries
                    let chronicDiseases = userInfo.chronicDiseases
                    DispatchQueue.main.async {
                        self.userInfo = UserInfo(uid: uid, bmiValue: bmiValue, bmiAdvice: bmiAdvice, height: height, weight: weight, physicalCondition: physicalCondition, birthDate: birthDate, gender: gender, previousActivity: previousActivity, injuries: injuries, chronicDiseases: chronicDiseases)
                    }
                }
            case "users":
                if let user = User(snapshot: querySnapshot){
                    let fullName = user.full_name
                    let email = user.email
                    let profilePicture = user.profile_picture
                    let uid = user.uid
                    let admin = user.admin
                    DispatchQueue.main.async {
                        self.user = User(uid: uid, full_name: fullName, email: email, profile_picture: profilePicture, admin: admin)
                    }
                }
            default:
                break
            }
        }
    }
    
    func logOut() {
        status = false
        self.defaults.set(false, forKey: Constants.UserDefaults.isLoggedIn)
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        LoginManager().logOut()
    }
    
    func updateImage() {
        isLoading = true
        firbaseService.uploadImage(imageData: img_data, path: "profile_picture", fileExtension: ".png") { (url) in
            self.updateUser(key: "profile_picture", value: "\(url)")
            self.isLoading = false
            self.fetchUser(collection: "users")
        }
    }
    
    func updateDetails(field: String) {
        ErrorAlert.alertView(msg: "Update \(field)") { (txt) in
            if txt != "" {
                switch field {
                case "name":
                    self.updateUser(key: "full_name", value: txt)
                case "email":
                    Auth.auth().currentUser?.updateEmail(to: txt, completion: { (error) in
                        if error == nil {
                            self.updateUser(key: "email", value: txt)
                        } else {
                            print("Error updating email \(error as Any)")
                            self.error = error!.localizedDescription                        }
                    })
                case "gender":
                    self.updateUserInfo(key: "gender", value: txt)
                case "physical condition":
                    self.updateUserInfo(key: "physical_condition", value: txt)
                case "previous activity":
                    self.updateUserInfo(key: "previous_activity", value: txt)
                case "injuries":
                    self.updateUserInfo(key: "injuries", value: txt)
                case "chronic diseases":
                    self.updateUserInfo(key: "chronic_diseases", value: txt)
                default:
                    break
                }
            }
        }
    }
    
    func updateUser(key: String, value: String){
        self.db.collection("users").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (query, error) in
            if let snapshot = query?.documents{
                for snap in snapshot {
                    let documentID = snap.documentID
                    self.db.collection("users").document(documentID).updateData([key : value])
                    self.fetchUser(collection: "users")
                }
            }
        }
    }
    
    func updateUserInfo(key: String, value: Any){
        self.db.collection("users_info").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { (query, error) in
            if let snapshot = query?.documents{
                for snap in snapshot {
                    let documentID = snap.documentID
                    self.db.collection("users_info").document(documentID).updateData([key : value])
                    self.fetchUser(collection: "users_info")
                }
            }
        }
    }
    
    func calculateBmi(){
        bmiCalculator.calculateBMI(height: Float(height)!, weight: Float(weight)!)
        let advice = bmiCalculator.getBMI()["bmiAdvice"]
        let value = bmiCalculator.getBMI()["bmiValue"]
        self.updateUserInfo(key: "bmi_advice", value: advice!)
        self.updateUserInfo(key: "bmi_value", value: value!)
    }
}
