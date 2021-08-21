//
//  MessagesTests.swift
//  FittyTests
//
//  Created by Filip Popovic
//

import XCTest
import Firebase
@testable import Fitty

class MessagesTests: XCTestCase {
    
    var chatListVC: ChatListViewController!
    var firstVC: FirstViewController!
    var user: [(email: String, password: String, uid: String)] = []
    var trainer: [(email: String, password: String, uid: String)] = []
    var usersTrainers: [(email: String, password: String, uid: String)] = []
    
    override func setUpWithError() throws {
        user = [
            (email: "filip@filip.com", password: "filipfilip", uid: "w42mJrNUNsNqKRuCwf2xM3gKidV2"),
            (email: "marko@marko.com", password: "filipfilip", uid: "VNNBq5MHyccMZ9fCeA1wq34lBB43")
        ]
        
        trainer = [
            (email: "vuk@vuk.com", password: "filipfilip", uid: "1k940WII11SjWKJmfRnQuFCJ2L83"),
            (email: "bojan@bojan.com", password: "filipfilip", uid: "6fkecr8oOxdhgY9v6TMWMAKcXp52")
        ]
        
        usersTrainers = user + trainer
    }
    
    override func tearDownWithError() throws {
        firstVC = nil
        chatListVC = nil
        try Auth.auth().signOut()
    }
    
    override func setUp() {
        super.setUp()
        try! Auth.auth().signOut()
        user = [
            (email: "filip@filip.com", password: "filipfilip", uid: "w42mJrNUNsNqKRuCwf2xM3gKidV2"),
            (email: "marko@marko.com", password: "filipfilip", uid: "VNNBq5MHyccMZ9fCeA1wq34lBB43")
        ]
        
        trainer = [
            (email: "vuk@vuk.com", password: "filipfilip", uid: "1k940WII11SjWKJmfRnQuFCJ2L83"),
            (email: "bojan@bojan.com", password: "filipfilip", uid: "6fkecr8oOxdhgY9v6TMWMAKcXp52")
        ]
        
        usersTrainers = user + trainer
    }
    
    override func tearDown() {
        firstVC = nil
        chatListVC = nil
        try! Auth.auth().signOut()
        super.tearDown()
    }
    
    func addChatListVC(){
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        chatListVC = storyboard.instantiateViewController(withIdentifier: "ChatListVC") as? ChatListViewController
        chatListVC.loadViewIfNeeded()
    }
    
    func addFirstVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.firstVC = storyboard.instantiateViewController(withIdentifier: "FirstVC") as? FirstViewController
        self.firstVC.loadViewIfNeeded()
    }
    
    func testMessagesCountForUser() throws {
        let expectation = self.expectation(description: "testMessagesCountForUser")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: self.user[1].email, password: self.user[1].password) { (_, _) in
            Firestore.firestore().collection("users").getDocuments { (querySnapshot, error) in
                var userNew = User()
                if let user = User(snapshot: querySnapshot){
                    userNew = user
                }
                User.setCurrent(userNew)
                
                _ = ChatService.observeChats { (_, chats) in
                    XCTAssertEqual(chats.count, 1)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testMessagesCountForTrainer() throws {
        let expectation = self.expectation(description: "testMessagesCountForTrainer")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: self.trainer[1].email, password: self.trainer[1].password) { (_, _) in
            Firestore.firestore().collection("users").getDocuments { (querySnapshot, error) in
                var userNew = User()
                if let user = User(snapshot: querySnapshot){
                    userNew = user
                }
                User.setCurrent(userNew)
                
                _ = ChatService.observeChats { (_, chats) in
                    XCTAssertEqual(chats.count, 0)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testLastMessageForUser() {
        let expectation = self.expectation(description: "testLastMessageForUser")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
       
            Auth.auth().signIn(withEmail: self.user[1].email, password: self.user[1].password) { (_, _) in
                Firestore.firestore().collection("users").getDocuments { (querySnapshot, error) in
                    var userNew = User()
                    if let user = User(snapshot: querySnapshot){
                        userNew = user
                    }
                    User.setCurrent(userNew)
                    self.addChatListVC()
                    self.chatListVC.hasTheFunctionCalled = true
                    self.chatListVC.viewWillAppear(true)
                    self.chatListVC.viewDidLoad()
                    let tableView = self.chatListVC.tableView
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        for cell in tableView!.visibleCells {
                            for view in cell.subviews where view.viewWithTag(11) != nil {
                                let titleLabel = view.viewWithTag(11) as! UILabel
                                let messageLabel = view.viewWithTag(22) as! UILabel
                                XCTAssertEqual(titleLabel.text, "Vuk Vukasinovic")
                                XCTAssertEqual(messageLabel.text, "Marko Popovic: Cao Vuce")
                                expectation.fulfill()
                            }
                        }
                    })
                }
            }
        wait(for: [expectation], timeout: 20)
    }
    
    func testLastMessageForTrainer() {
        let expectation = self.expectation(description: "testLastMessageForTrainer")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
       
            Auth.auth().signIn(withEmail: self.trainer[1].email, password: self.trainer[1].password) { (_, _) in
                Firestore.firestore().collection("users").getDocuments { (querySnapshot, error) in
                    var userNew = User()
                    if let user = User(snapshot: querySnapshot){
                        userNew = user
                    }
                    User.setCurrent(userNew)
                    self.addChatListVC()
                    self.chatListVC.hasTheFunctionCalled = true
                    self.chatListVC.viewWillAppear(true)
                    self.chatListVC.viewDidLoad()
                    let tableView = self.chatListVC.tableView
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        XCTAssertEqual(tableView!.visibleCells.count, 0)
                        expectation.fulfill()
                    })
                }
            }
        wait(for: [expectation], timeout: 20)
    }
    
    static var allTests: [(String, (MessagesTests) -> () throws -> Void)] {
        return [
            ("testMessagesCountForUser", testMessagesCountForUser),
            ("testLastMessageForUser", testLastMessageForUser),
            ("testMessagesCountForTrainer", testMessagesCountForTrainer),
            ("testLastMessageForTrainer", testLastMessageForTrainer)
        ]
    }
    
}
