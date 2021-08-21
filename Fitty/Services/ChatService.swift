//
//  ChatService.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import Firebase

struct ChatService {
    
    static func create(from message: Message, with chat: Chat, completion: @escaping (Chat?) -> Void) {
        var membersDict = [String : Bool]()
        for uid in chat.memberUIDs {
            membersDict[uid] = true
        }
        let lastMessage = "\(message.sender.full_name): \(message.content)"
        chat.lastMessage = lastMessage
        let lastMessageSent = message.timestamp.timeIntervalSince1970
        chat.lastMessageSent = message.timestamp
        let chatDict: [String : Any] = ["title" : chat.title,
                                        "memberHash" : chat.memberHash,
                                        "members" : membersDict,
                                        "lastMessage" : lastMessage,
                                        "lastMessageSent" : lastMessageSent]
        
        let chatRef = Database.database().reference().child("chats").child(User.current.uid).childByAutoId()
        chat.key = chatRef.key
        var multiUpdateValue = [String : Any]()
        for uid in chat.memberUIDs {
            multiUpdateValue["chats/\(uid)/\(String(describing: chatRef.key!))"] = chatDict
        }
        let messagesRef = Database.database().reference().child("messages").child(chatRef.key!).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["messages/\(String(describing: chatRef.key!))/\(String(describing: messageKey!))"] = message.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return
            }
            completion(chat)
        }
    }
    
    static func checkForExistingChat(with user: User, completion: @escaping (Chat?) -> Void) {
        let members = [user, User.current]
        let hashValue = Chat.hash(forMembers: members)
        let chatRef = Database.database().reference().child("chats").child(User.current.uid)
        let query = chatRef.queryOrdered(byChild: "memberHash").queryEqual(toValue: hashValue)
        
        chatRef.queryOrdered(byChild: "memberHash").getData { (er, data) in
        }
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let chatSnap = snapshot.children.allObjects.first as? DataSnapshot,
                  let chat = Chat(snapshot: chatSnap)
            else { return completion(nil) }
            completion(chat)
        })
    }
    
    static func sendMessage(_ message: Message, for chat: Chat, success: ((Bool) -> Void)? = nil) {
        guard let chatKey = chat.key else {
            success?(false)
            return
        }
        var multiUpdateValue = [String : Any]()
        for uid in chat.memberUIDs {
            let lastMessage = "\(message.sender.full_name): \(message.content)"
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessage"] = lastMessage
            multiUpdateValue["chats/\(uid)/\(chatKey)/lastMessageSent"] = message.timestamp.timeIntervalSince1970
        }
        let messagesRef = Database.database().reference().child("messages").child(chatKey).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["messages/\(chatKey)/\(String(describing: messageKey!))"] = message.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            success?(true)
        })
    }
    
    static func observeMessages(forChatKey chatKey: String, completion: @escaping (DatabaseReference, Message?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child("messages").child(chatKey)
        
        return messagesRef.observe(.childAdded, with: { snapshot in
            guard let message = Message(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
            completion(messagesRef, message)
        })
    }
    
    static func observeChats(for user: User = User.current, withCompletion completion: @escaping (DatabaseReference, [Chat]) -> Void) -> DatabaseHandle {
        let ref = Database.database().reference().child("chats").child(user.uid)
        
        return ref.observe(.value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(ref, [])
            }
            let chats = snapshot.compactMap(Chat.init)
            completion(ref, chats)
        })
    }
    
    static func updateExistingChat(with user: User, key: String) {
        let chatRef = Database.database().reference().child("chats").child(User.current.uid)
        chatRef.getData { (err, snapshot) in
            guard let snap = snapshot.children.allObjects.first as? DataSnapshot else { return }
            if let chat = Chat(snapshot: snap) {
                let newTitle = chat.title.split(separator: ",")
                let lastMessage = chat.lastMessage?.split(separator: ":")
                if newTitle[0] != user.full_name && lastMessage![0] != user.full_name {
                    var slice1 = String(newTitle[0])
                    let slice2 = String(newTitle[1])
                    slice1 = user.full_name
                    var lastMessageSlice1 = String(lastMessage![0])
                    let lastMessageSlice2 = String(lastMessage![1])
                    lastMessageSlice1 = user.full_name
                    Database.database().reference().updateChildValues(["chats/\(user.uid)/\(String(describing: chat.key!))/title" : slice1 + "," + slice2])
                    Database.database().reference().updateChildValues(["chats/\(user.uid)/\(String(describing: chat.key!))/lastMessage" : lastMessageSlice1 + ": " + lastMessageSlice2])
                }
                chat.memberUIDs.forEach{ uid in
                    if uid != user.uid {
                        let chatRef = Database.database().reference().child("chats").child(uid)
                        chatRef.getData { (err, snapshot) in
                            guard let snap = snapshot.children.allObjects.first as? DataSnapshot else { return }
                            if let ch = Chat(snapshot: snap) {
                                let newTitle = ch.title.split(separator: ",")
                                let lastMessage = chat.lastMessage?.split(separator: ":")
                                if newTitle[1] != user.full_name && lastMessage![0] != user.full_name {
                                    let slice1 = String(newTitle[0])
                                    var slice2 = String(newTitle[1])
                                    slice2 = user.full_name
                                    var lastMessageSlice1 = String(lastMessage![0])
                                    let lastMessageSlice2 = String(lastMessage![1])
                                    lastMessageSlice1 = user.full_name
                                    Database.database().reference().updateChildValues(["chats/\(uid)/\(String(describing: chat.key!))/title" : slice1 + ", " + slice2])
                                    Database.database().reference().updateChildValues(["chats/\(uid)/\(String(describing: chat.key!))/lastMessage" : lastMessageSlice1 + ": " + lastMessageSlice2])
                                }
                            }
                        }
                    }
                }
                let messagesRef = Database.database().reference().child("messages").child(chat.key!)
                messagesRef.getData { (err, snapshot) in
                    guard let messages = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    for message in messages {
                    print("Snap \(message)")
                    if let message = Message(snapshot: message) {
                        let newFullName = message.sender.full_name
                        let uid = message.sender.uid
                        if newFullName != user.full_name && uid == user.uid {
                            Database.database().reference().updateChildValues(["messages/\(String(describing: chat.key!))/\(String(describing: message.key!))/sender/username" : user.full_name])
                        }
                    }
                    }
                }
                
            }
        }
        
       
    }
}
