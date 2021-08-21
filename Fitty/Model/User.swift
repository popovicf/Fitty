//
//  User.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import Firebase

struct User: Equatable, Hashable {
    
    var uid: String = ""
    var full_name: String = ""
    var profile_picture: String = ""
    var email: String = ""
    var isFollowed: Bool = false
    var admin: Bool = false
    static var userInstance = User(uid: "", full_name: "", email: "", profile_picture: "", admin: false)
    
    private static var _current: User?
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }
    static func setCurrent(_ user: User) {
        _current = user
    }
    
    init() {
    }
    
    init(uid: String, full_name: String) {
        self.uid = uid
        self.full_name = full_name
    }
    
    init(uid: String, full_name: String, email: String, profile_picture: String, admin: Bool) {
        self.uid = uid
        self.full_name = full_name
        self.email = email
        self.profile_picture = profile_picture
        self.admin = admin
    }
    
    init?(snapshot: QuerySnapshot?) {
        if let snap = snapshot?.documents{
            for s in snap{
                let data = s.data()
                if let UID = data["uid"] as? String{
                    if UID == Auth.auth().currentUser?.uid {
                        self.uid = UID
                        self.full_name = data["full_name"] as! String
                        self.profile_picture = data["profile_picture"] as! String
                        self.email = data["email"] as! String
                        self.admin = data["admin"] as! Bool
                    }
                }
            }
        }
    }
    
    init?(allUsersSnap: QuerySnapshot?) {
        if let snap = allUsersSnap?.documents{
            for s in snap{
                let data = s.data()
                        self.uid = data["uid"] as! String
                        self.full_name = data["full_name"] as! String
                        self.profile_picture = data["profile_picture"] as! String
                        self.email = data["email"] as! String
                        self.admin = data["admin"] as! Bool
            }
        }
    }
    
    init?(userID: String, snapshot: QuerySnapshot?) {
        if let snap = snapshot?.documents{
            for s in snap{
                let data = s.data()
                if let UID = data["uid"] as? String{
                    if UID == userID {
                        self.uid = UID
                        self.full_name = data["full_name"] as! String
                        self.profile_picture = data["profile_picture"] as! String
                        self.email = data["email"] as! String
                        self.admin = data["admin"] as! Bool
                    }
                }
            }
        }
    }
}
