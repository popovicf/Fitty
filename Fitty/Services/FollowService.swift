//
//  FollowService.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import Firebase

struct FollowService {
    
    private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        
        db.collection("followers").getDocuments { (querySnap, error) in
            if let snap = querySnap?.documents {
                for s in snap {
                    if user.uid != s.documentID {
                        db.collection("followers").document(user.uid).setData(["dict": FieldValue.arrayUnion([["uid":currentUID, "isFollowed":true]])], merge: true) { (error) in
                            if let error = error {
                                assertionFailure(error.localizedDescription)
                            }
                            success(error==nil)
                        }
                    } else {
                        db.collection("followers").document(user.uid).updateData(["dict": FieldValue.arrayUnion([["uid":currentUID, "isFollowed":true]])]) { (error) in
                            if let error = error {
                                assertionFailure(error.localizedDescription)
                            }
                            db.collection("followers").document(user.uid).updateData(["dict": FieldValue.arrayRemove([["uid":currentUID, "isFollowed":false]])]) { (error) in
                                if let error = error {
                                    assertionFailure(error.localizedDescription)
                                }
                                success(error==nil)
                            }
                        }
                    }
                }
            }
        }
        
        db.collection("following").getDocuments { (querySnap, error) in
            if let snap = querySnap?.documents {
                for s in snap {
                    if currentUID != s.documentID {
                        db.collection("following").document(currentUID).setData(["dict": FieldValue.arrayUnion([["uid":user.uid, "isFollowing":true]])], merge: true) { (error) in
                            if let error = error {
                                assertionFailure(error.localizedDescription)
                            }
                            success(error==nil)
                        }
                    } else {
                        db.collection("following").document(currentUID).updateData(["dict": FieldValue.arrayUnion([["uid":user.uid, "isFollowing":true]])]) { (error) in
                            if let error = error {
                                assertionFailure(error.localizedDescription)
                            }
                            db.collection("following").document(currentUID).updateData(["dict": FieldValue.arrayRemove([["uid":user.uid, "isFollowing":false]])]) { (error) in
                                if let error = error {
                                    assertionFailure(error.localizedDescription)
                                }
                                success(error==nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        let currentUID = Auth.auth().currentUser!.uid
        let db = Firestore.firestore()
        
        db.collection("followers").document(user.uid).updateData(["dict": FieldValue.arrayUnion([["uid":currentUID, "isFollowed":false]])]) { (error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            db.collection("followers").document(user.uid).updateData(["dict": FieldValue.arrayRemove([["uid":currentUID, "isFollowed":true]])]) { (error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                success(error==nil)
            }
        }
        
        db.collection("following").document(currentUID).updateData(["dict": FieldValue.arrayUnion([["uid":user.uid, "isFollowing":false]])]) { (error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            db.collection("following").document(currentUID).updateData(["dict": FieldValue.arrayRemove([["uid":user.uid, "isFollowing":true]])]) { (error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                }
                success(error==nil)
            }
        }
    }
    
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo follower: User, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(follower, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(follower, forCurrentUserWithSuccess: success)
        }
    }
    
    static func isUserFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let refFollowers = Firestore.firestore().collection("followers").document(user.uid)
        var res: [Bool] = []
        
        refFollowers.getDocument { (docSnapshot, error) in
            if let document = docSnapshot, docSnapshot!.exists {
                let userNotifications = document.data()!["dict"] as? [[String:Any]]
                for notificaton in userNotifications!  {
                    let uid = notificaton["uid"] as! String
                    let isFollowed = notificaton["isFollowed"] as! Bool
                    if uid == Auth.auth().currentUser?.uid{
                        switch isFollowed {
                        case true:
                            res.append(true)
                        case false:
                            res.append(false)
                        }
                    } else {
                        res.append(false)
                    }
                }
                if res.contains(true) {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    static func isAdminFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let refFollowers = Firestore.firestore().collection("followers").document(Auth.auth().currentUser!.uid)
        var res: [Bool] = []
        
        refFollowers.getDocument { (docSnapshot, error) in
            if let document = docSnapshot, docSnapshot!.exists {
                let userNotifications = document.data()!["dict"] as? [[String:Any]]
                for notificaton in userNotifications!  {
                    let uid = notificaton["uid"] as! String
                    let isFollowed = notificaton["isFollowed"] as! Bool
                    if uid == user.uid{
                        switch isFollowed {
                        case true:
                            res.append(true)
                        case false:
                            res.append(false)
                        }
                    } else {
                        res.append(false)
                    }
                }
                if res.contains(true) {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void, completionUserInfo: @escaping ([UserInfo]) -> Void) {
        var users = [User]()
        var user = User()
        var usersInfo = [UserInfo]()
        var userInfo = UserInfo()
        
        Firestore.firestore().collection("users").whereField("uid", isNotEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
            if let snap = snapshot {
                for s in snap.documents {
                    let data = s.data()
                    if data["admin"] as! Bool == true {
                        user.uid = data["uid"] as! String
                        user.full_name = data["full_name"] as! String
                        user.profile_picture = data["profile_picture"] as! String
                        user.email = data["email"] as! String
                        user.admin = data["admin"] as! Bool
                        users.append(user)
                    }
                }
                
                var us = User()
                var userList = [User]()
                let dispatchGroup = DispatchGroup()
                for user in users {
                    Firestore.firestore().collection("users_info").whereField("uid", isNotEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
                        if let snap = snapshot {
                            for s in snap.documents {
                                let data = s.data()
                                if user.uid == data["uid"] as! String {
                                    userInfo.uid = data["uid"] as! String
                                    userInfo.birthDate = data["birth_date"] as? Timestamp
                                    userInfo.gender = data["gender"] as! String
                                    userInfo.height = data["height"] as! String
                                    userInfo.weight = data["weight"] as! String
                                    userInfo.physicalCondition = data["physical_condition"] as! String
                                    userInfo.previousActivity = data["previous_activity"] as! String
                                    userInfo.chronicDiseases = data["chronic_diseases"] as! String
                                    userInfo.injuries = data["injuries"] as! String
                                    userInfo.bmiAdvice = data["bmi_advice"] as! String
                                    userInfo.bmiValue = data["bmi_value"] as! String
                                    usersInfo.append(userInfo)
                                }
                            }
                        }
                    }
                    dispatchGroup.enter()
                    FollowService.isUserFollowed(user) { (isFollowed) in
                        us = user
                        us.isFollowed = isFollowed
                        userList.append(us)
                        users = userList
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main, execute: {
                    completion(users)
                    completionUserInfo(usersInfo)
                })
            }
        }
    }
    
    static func adminClientsList(completion: @escaping ([User]) -> Void, completionUserInfo: @escaping ([UserInfo]) -> Void) {
        var users = [User]()
        var user = User()
        var usersInfo = [UserInfo]()
        var userInfo = UserInfo()
        var usersInfoRes = [UserInfo]()
        
        Firestore.firestore().collection("users").whereField("uid", isNotEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
            if let snap = snapshot {
                for s in snap.documents {
                    let data = s.data()
                    if data["admin"] as! Bool == false {
                        user.uid = data["uid"] as! String
                        user.full_name = data["full_name"] as! String
                        user.profile_picture = data["profile_picture"] as! String
                        user.email = data["email"] as! String
                        user.admin = data["admin"] as! Bool
                        users.append(user)
                    }
                }
                var us = User()
                var userList = [User]()
                let dispatchGroup = DispatchGroup()
                for user in users {
                    Firestore.firestore().collection("users_info").whereField("uid", isNotEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
                        if let snap = snapshot {
                            for s in snap.documents {
                                let data = s.data()
                                if user.uid == data["uid"] as! String {
                                    userInfo.uid = data["uid"] as! String
                                    userInfo.birthDate = data["birth_date"] as? Timestamp
                                    userInfo.gender = data["gender"] as! String
                                    userInfo.height = data["height"] as! String
                                    userInfo.weight = data["weight"] as! String
                                    userInfo.physicalCondition = data["physical_condition"] as! String
                                    userInfo.previousActivity = data["previous_activity"] as! String
                                    userInfo.chronicDiseases = data["chronic_diseases"] as! String
                                    userInfo.injuries = data["injuries"] as! String
                                    userInfo.bmiAdvice = data["bmi_advice"] as! String
                                    userInfo.bmiValue = data["bmi_value"] as! String
                                    usersInfo.append(userInfo)
                                }
                            }
                        }
                    }
                    dispatchGroup.enter()
                    FollowService.isAdminFollowed(user) { (isFollowed) in
                        us = user
                        us.isFollowed = isFollowed
                        if us.isFollowed == true {
                            userList.append(us)
                        }
                        users = userList
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main, execute: {
                    completion(users)
                    
                    var uids = [String]()
                    for u in users {
                        uids.append(u.uid)
                    }
                    for info in usersInfo where uids.contains(info.uid){
                        usersInfoRes.append(info)
                    }
                    completionUserInfo(usersInfoRes)
                })
            }
        }
    }
    
    static func adminsList(completion: @escaping ([User]) -> Void, completionUserInfo: @escaping ([UserInfo]) -> Void) {
        var users = [User]()
        var user = User()
        var usersInfo = [UserInfo]()
        var userInfo = UserInfo()
        
        Firestore.firestore().collection("users").whereField("uid", isNotEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
            if let snap = snapshot {
                for s in snap.documents {
                    let data = s.data()
                    if data["admin"] as! Bool == true {
                        user.uid = data["uid"] as! String
                        user.full_name = data["full_name"] as! String
                        user.profile_picture = data["profile_picture"] as! String
                        user.email = data["email"] as! String
                        user.admin = data["admin"] as! Bool
                        users.append(user)
                    }
                }
                var us = User()
                var userList = [User]()
                let dispatchGroup = DispatchGroup()
                for user in users {
                    Firestore.firestore().collection("users_info").whereField("uid", isNotEqualTo: Auth.auth().currentUser!.uid).getDocuments { (snapshot, error) in
                        if let snap = snapshot {
                            for s in snap.documents {
                                let data = s.data()
                                if user.uid == data["uid"] as! String {
                                    userInfo.uid = data["uid"] as! String
                                    userInfo.birthDate = data["birth_date"] as? Timestamp
                                    userInfo.gender = data["gender"] as! String
                                    userInfo.height = data["height"] as! String
                                    userInfo.weight = data["weight"] as! String
                                    userInfo.physicalCondition = data["physical_condition"] as! String
                                    userInfo.previousActivity = data["previous_activity"] as! String
                                    userInfo.chronicDiseases = data["chronic_diseases"] as! String
                                    userInfo.injuries = data["injuries"] as! String
                                    userInfo.bmiAdvice = data["bmi_advice"] as! String
                                    userInfo.bmiValue = data["bmi_value"] as! String
                                    usersInfo.append(userInfo)
                                }
                            }
                        }
                    }
                    dispatchGroup.enter()
                    FollowService.isUserFollowed(user) { (isFollowed) in
                        us = user
                        us.isFollowed = isFollowed
                        if us.isFollowed == true {
                            userList.append(us)
                        }
                        users = userList
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main, execute: {
                    completion(users)
                    completionUserInfo(usersInfo)
                })
            }
        }
    }
    
    static func following(for user: User = User.current, completion: @escaping ([User]) -> Void) {
        let followingReference = Firestore.firestore().collection("following").document(user.uid)
        
        followingReference.getDocument { (documentSnap, error) in
            guard let followingDict = documentSnap?.data() else {
                return completion([])
            }
            
            var following = [User]()
            let values = followingDict.values.description.split(separator: ",")
            
            for value in values where value.contains("isFollowing = 1") {
                let ID = value.split(separator: ";")[1].replacingOccurrences(of: "uid = ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                Firestore.firestore().collection("users").whereField("uid", isEqualTo: ID).getDocuments { (querySnap, error) in
                    if let user = User(allUsersSnap: querySnap) {
                        following.append(user)
                        completion(following)
                    }
                }
            }
        }
    }
    
    static func followingTrainer(for userUID: String = Auth.auth().currentUser?.uid ?? " ", completion: @escaping ([String]) -> Void) {
        let followingReference = Firestore.firestore().collection("following").document(userUID)
        var ids = [String]()
        followingReference.getDocument { (documentSnap, error) in
            guard let followingDict = documentSnap?.data() else {
                return completion([])
            }
            let values = followingDict.values.description.split(separator: ",")
            
            for value in values where value.contains("isFollowing = 1") {
                let ID = value.split(separator: ";")[1].replacingOccurrences(of: "uid = ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                ids.append(ID)
            }
            completion(ids)
        }
    }
    
    static func followers(for user: User = User.current, completion: @escaping ([User]) -> Void) {
        let followingReference = Firestore.firestore().collection("followers").document(user.uid)
        
        followingReference.getDocument { (documentSnap, error) in
            guard let followersDict = documentSnap?.data() else {
                return completion([])
            }
            
            var followers = [User]()
            let values = followersDict.values.description.split(separator: ",")
            
            for value in values where value.contains("isFollowed = 1") {
                let ID = value.split(separator: ";")[1].replacingOccurrences(of: "uid = ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                Firestore.firestore().collection("users").whereField("uid", isEqualTo: ID).getDocuments { (querySnap, error) in
                    if let user = User(allUsersSnap: querySnap) {
                        followers.append(user)
                        completion(followers)
                    }
                }
            }
        }
    }
    
}
