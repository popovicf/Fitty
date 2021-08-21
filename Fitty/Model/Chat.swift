//
//  Chat.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import Firebase

class Chat {
    
    var key: String?
    let title: String
    let memberHash: String
    let memberUIDs: [String]
    var lastMessage: String?
    var lastMessageSent: Date?
    
    init?(snapshot: DataSnapshot) {
        guard !snapshot.key.isEmpty,
              let dict = snapshot.value as? [String : Any],
              let title = dict["title"] as? String,
              let memberHash = dict["memberHash"] as? String,
              let membersDict = dict["members"] as? [String : Bool],
              let lastMessage = dict["lastMessage"] as? String,
              let lastMessageSent = dict["lastMessageSent"] as? TimeInterval
        else { return nil }
        
        self.key = snapshot.key
        self.title = title
        self.memberHash = memberHash
        self.memberUIDs = Array(membersDict.keys)
        self.lastMessage = lastMessage
        self.lastMessageSent = Date(timeIntervalSince1970: lastMessageSent)
    }
    
    init(members: [User]){
        assert(members.count == 2, "There must be two members in a chat.")
        self.title = members.reduce("") { (acc, cur) -> String in
            return acc.isEmpty ? cur.full_name : "\(acc), \(cur.full_name)"
        }
        self.memberHash = Chat.hash(forMembers: members)
        self.memberUIDs = members.map { $0.uid }
    }
    
    static func hash(forMembers members: [User]) -> String {
        guard members.count == 2 else {
            fatalError("There must be two members to compute member hash.")
        }
        
        let firstMember = members[0]
        let secondMember = members[1]
        
        let memberHash = String(firstMember.uid.hash ^ secondMember.uid.hash)
        return memberHash
    }
    
}
