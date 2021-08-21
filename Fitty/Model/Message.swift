//
//  Message.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import Firebase

class Message {
    
    var key: String?
    let content: String
    let timestamp: Date
    let sender: User
    var dictValue: [String : Any] {
        let userDict = ["username" : sender.full_name,
                        "uid" : sender.uid]
        
        return ["sender" : userDict,
                "content" : content,
                "timestamp" : timestamp.timeIntervalSince1970]
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
              let content = dict["content"] as? String,
              let timestamp = dict["timestamp"] as? TimeInterval,
              let userDict = dict["sender"] as? [String : Any],
              let uid = userDict["uid"] as? String,
              let username = userDict["username"] as? String
        else { return nil }
        
        self.key = snapshot.key
        self.content = content
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.sender = User(uid: uid, full_name: username)
    }
    
    init(content: String) {
        self.content = content
        self.timestamp = Date()
        self.sender = User.current
    }
}
