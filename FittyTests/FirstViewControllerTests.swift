//
//  FirstViewControllerTests.swift
//  FittyTests
//
//  Created by Filip Popovic
//

import XCTest
import Firebase
@testable import Fitty

class FirstViewControllerTests: XCTestCase {
    
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
        try! Auth.auth().signOut()
        super.tearDown()
    }
    
    func testTrainersListFull() {
        let expectation = self.expectation(description: "testTrainersListFull")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        var hasTrainers = false
        
        Auth.auth().signIn(withEmail: user[0].email, password: user[0].password) { (_, _) in
            FollowService.adminsList { (user) in
                if !user.isEmpty {
                    hasTrainers = true
                }
                expectation.fulfill()
            } completionUserInfo: { _ in }
        }
        wait(for: [expectation], timeout: 10)
        XCTAssertTrue(hasTrainers)
    }
    
    func testClientsListFull() {
        let expectation = self.expectation(description: "testClientsListFull")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        var hasTrainers = false
        
        Auth.auth().signIn(withEmail: trainer[0].email, password: trainer[0].password) { (_, _) in
            FollowService.adminClientsList { (client) in
                if !client.isEmpty { hasTrainers = true }
                expectation.fulfill()
            } completionUserInfo: { (clientInfo) in
                if !clientInfo.isEmpty { hasTrainers = true }
            }
        }
        wait(for: [expectation], timeout: 10)
        XCTAssertTrue(hasTrainers)
    }
    
    func testTrainersListEmpty() {
        let expectation = self.expectation(description: "testTrainersListEmpty")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        var hasTrainers = false
        
        Auth.auth().signIn(withEmail: user[1].email, password: user[1].password) { (_, _) in
            FollowService.adminsList { (user) in
                if !user.isEmpty { hasTrainers = true }
                expectation.fulfill()
            } completionUserInfo: { _ in }
        }
        wait(for: [expectation], timeout: 10)
        XCTAssertFalse(hasTrainers)
    }
    
    func testClientsListEmpty() {
        let expectation = self.expectation(description: "testClientsListEmpty")
        expectation.expectedFulfillmentCount = 2
        expectation.assertForOverFulfill = true
        var hasTrainers = true
        
        Auth.auth().signIn(withEmail: trainer[1].email, password: trainer[1].password) { (_, _) in
            FollowService.adminClientsList { (client) in
                if client.isEmpty { hasTrainers = false }
                expectation.fulfill()
            } completionUserInfo: { (clientInfo) in
                if clientInfo.isEmpty { hasTrainers = false }
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
        XCTAssertFalse(hasTrainers)
    }
    
    func testHeaderTitle() throws {
        let expectation = self.expectation(description: "testHeaderTitle")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: self.usersTrainers.randomElement()!.email, password: self.usersTrainers.randomElement()!.password) { (_, _) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.firstVC = storyboard.instantiateViewController(withIdentifier: "FirstVC") as? FirstViewController
                self.firstVC.loadViewIfNeeded()
                self.firstVC.hasTheFunctionCalled = true
                self.firstVC.viewWillAppear(true)
                self.firstVC.viewDidLoad()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    Firestore.firestore().collection("users").getDocuments { (snapshot, _) in
                        guard let user = User(snapshot: snapshot) else { return }
                        self.firstVC.isAdmin = user.admin
                        let headerView = self.firstVC.tableView.delegate?.tableView?(self.firstVC.tableView, viewForHeaderInSection: 0)
                        
                        for view in headerView!.subviews where (view.viewWithTag(27) != nil){
                            let button = view.viewWithTag(27)! as! UIButton
                            
                            switch self.firstVC.isAdmin {
                            case true:
                                XCTAssertEqual(button.currentTitle!, "Find your client")
                            case false:
                                XCTAssertEqual(button.currentTitle!, "Find your trainer")
                            }
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 20)
    }
    
    func testNameOfTrainersSection() throws {
        let expectationTrainer = self.expectation(description: "testNameOfTrainersSection")
        expectationTrainer.expectedFulfillmentCount = 1
        expectationTrainer.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: self.trainer.randomElement()!.email, password: self.trainer.randomElement()!.password) { (_, _) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.firstVC = storyboard.instantiateViewController(withIdentifier: "FirstVC") as? FirstViewController
                self.firstVC.loadViewIfNeeded()
                self.firstVC.hasTheFunctionCalled = true
                self.firstVC.viewWillAppear(true)
                self.firstVC.viewDidLoad()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    Firestore.firestore().collection("users").getDocuments { (snapshot, _) in
                        guard let user = User(snapshot: snapshot) else { return }
                        self.firstVC.isAdmin = user.admin
                        var indexPath = IndexPath()
                        let tableView = self.firstVC.tableView
                        tableView?.reloadData()
                        
                        for cell in tableView!.visibleCells {
                            for view in cell.subviews where view.viewWithTag(11) != nil {
                                let label = view.viewWithTag(11) as! UILabel
                                indexPath = tableView!.indexPath(for: cell)!
                                
                                if indexPath.section == 1 && self.firstVC.isAdmin == false {
                                    XCTAssertEqual(label.text!, "Training Plan")
                                } else if indexPath.section == 2 && self.firstVC.isAdmin == false {
                                    XCTAssertEqual(label.text!, "Nutrition Plan")
                                } else {
                                    XCTAssertEqual(label.text!, "Training Report")
                                }
                                expectationTrainer.fulfill()
                            }
                        }
                    }
                }
            }
        }
        wait(for: [expectationTrainer], timeout: 20)
    }
    
    func testNameOfUsersSection() throws {
        let expectationUsers = self.expectation(description: "testNameOfUsersSection")
        expectationUsers.expectedFulfillmentCount = 2
        expectationUsers.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: self.user.randomElement()!.email, password: self.user.randomElement()!.password) { (_, _) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.firstVC = storyboard.instantiateViewController(withIdentifier: "FirstVC") as? FirstViewController
                self.firstVC.loadViewIfNeeded()
                self.firstVC.hasTheFunctionCalled = true
                self.firstVC.viewWillAppear(true)
                self.firstVC.viewDidLoad()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    Firestore.firestore().collection("users").getDocuments { (snapshot, _) in
                        guard let user = User(snapshot: snapshot) else { return }
                        self.firstVC.isAdmin = user.admin
                        var indexPath = IndexPath()
                        let tableView = self.firstVC.tableView
                        tableView?.reloadData()
                        
                        for cell in tableView!.visibleCells {
                            for view in cell.subviews where view.viewWithTag(11) != nil {
                                let label = view.viewWithTag(11) as! UILabel
                                indexPath = tableView!.indexPath(for: cell)!
                                
                                if indexPath.section == 1 && self.firstVC.isAdmin == false {
                                    XCTAssertEqual(label.text!, "Training Plan")
                                } else if indexPath.section == 2 && self.firstVC.isAdmin == false {
                                    XCTAssertEqual(label.text!, "Nutrition Plan")
                                } else {
                                    XCTAssertEqual(label.text!, "Training Report")
                                }
                                expectationUsers.fulfill()
                            }
                        }
                    }
                }
            }
        }
        wait(for: [expectationUsers], timeout: 20)
    }
    
    func testNumberOdSections() throws {
        let expectation = self.expectation(description: "testNumberOdSections")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: self.usersTrainers.randomElement()!.email, password: self.usersTrainers.randomElement()!.password) { (_, _) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.firstVC = storyboard.instantiateViewController(withIdentifier: "FirstVC") as? FirstViewController
                self.firstVC.loadViewIfNeeded()
                self.firstVC.hasTheFunctionCalled = true
                self.firstVC.viewWillAppear(true)
                self.firstVC.viewDidLoad()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    Firestore.firestore().collection("users").getDocuments { (snapshot, _) in
                        guard let user = User(snapshot: snapshot) else { return }
                        self.firstVC.isAdmin = user.admin
                        let tableView = self.firstVC.tableView
                        tableView?.reloadData()
                        
                        if self.firstVC.isAdmin == true {
                            XCTAssertEqual(tableView!.numberOfSections, 2)
                        } else {
                            XCTAssertEqual(tableView!.numberOfSections, 3)
                        }
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 20)
    }
    
    static var allTests: [(String, (FirstViewControllerTests) -> () throws -> Void)] {
        return [
            ("testTrainersListFull", testTrainersListFull),
            ("testClientsListFull", testClientsListFull),
            ("testTrainersListEmpty", testTrainersListEmpty),
            ("testClientsListEmpty", testClientsListEmpty),
            ("testHeaderTitle", testHeaderTitle),
            ("testNameOfTrainersSection", testNameOfTrainersSection),
            ("testNameOfUsersSection", testNameOfUsersSection),
            ("testNumberOdSections", testNumberOdSections)
        ]
    }
}
