//
//  TrainingPlanTests.swift
//  FittyTests
//
//  Created by Filip Popovic
//

import XCTest
import Firebase
@testable import Fitty

class TrainingAndNutritionPlanTests: XCTestCase {
    
    var nutritionPlanVC: NutritionPlanViewController!
    var trainingPlanVC: TrainingPlanViewController!
    var clientsInfoVC: ClientsInfoViewController!
    var clientsVC: ClientsViewController!
    var trainingPlanListVC: TrainingPlanListViewController!
    var trainingPlanListShow: ShowPlanViewController!
    var nutritionPlanListVC: NutritionPlanListViewController!
    var nutritionPlanListShow: ShowNutritionPlanViewController!
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
        nutritionPlanVC = nil
        trainingPlanVC = nil
        clientsInfoVC = nil
        clientsVC = nil
        nutritionPlanListVC = nil
        nutritionPlanListShow = nil
        trainingPlanListVC = nil
        trainingPlanListShow = nil
        try Auth.auth().signOut()
    }
    
    override func setUp() {
        super.setUp()
        try! Auth.auth().signOut()
    }
    
    override func tearDown() {
        nutritionPlanVC = nil
        trainingPlanVC = nil
        clientsInfoVC = nil
        clientsVC = nil
        nutritionPlanListVC = nil
        nutritionPlanListShow = nil
        trainingPlanListVC = nil
        trainingPlanListShow = nil
        try! Auth.auth().signOut()
        super.tearDown()
    }
    
    func addTrainingPlanListVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        trainingPlanListVC = storyboard.instantiateViewController(withIdentifier: "TrainingPlanListVC") as? TrainingPlanListViewController
        trainingPlanListVC.loadViewIfNeeded()
    }
    
    func addNutritionPlanListVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        nutritionPlanListVC = storyboard.instantiateViewController(withIdentifier: "NutritionPlanListVC") as? NutritionPlanListViewController
        nutritionPlanListVC.loadViewIfNeeded()
    }
    
    func addClientsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        clientsVC = storyboard.instantiateViewController(withIdentifier: "ClientsVC") as? ClientsViewController
        clientsVC.loadViewIfNeeded()
    }
    
    func addClientsInfoVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        clientsInfoVC = storyboard.instantiateViewController(withIdentifier: "ClientsInfoVC") as? ClientsInfoViewController
        clientsInfoVC.loadViewIfNeeded()
    }
    
    func addTrainingPlanVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        trainingPlanVC = storyboard.instantiateViewController(withIdentifier: "TrainingPlanVC") as? TrainingPlanViewController
        trainingPlanVC.user = User(uid: "7fVDHXx4RYaAr8MBlWK8xI7tg682", full_name: "Filip Popovic", email: "popovic.filip91@gmail.com", profile_picture: "https://firebasestorage.googleapis.com/v0/b/fitty-de298.appspot.com/o/profile_picture%2F7fVDHXx4RYaAr8MBlWK8xI7tg682%2F7fVDHXx4RYaAr8MBlWK8xI7tg682.png?alt=media&token=b26614c4-9818-479e-90af-950d9ae6126d", admin: false)
        trainingPlanVC.loadViewIfNeeded()
    }
    
    func addNutritionPlanVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        nutritionPlanVC = storyboard.instantiateViewController(withIdentifier: "NutritionPlanVC") as? NutritionPlanViewController
        nutritionPlanVC.user = User(uid: "7fVDHXx4RYaAr8MBlWK8xI7tg682", full_name: "Filip Popovic", email: "popovic.filip91@gmail.com", profile_picture: "https://firebasestorage.googleapis.com/v0/b/fitty-de298.appspot.com/o/profile_picture%2F7fVDHXx4RYaAr8MBlWK8xI7tg682%2F7fVDHXx4RYaAr8MBlWK8xI7tg682.png?alt=media&token=b26614c4-9818-479e-90af-950d9ae6126d", admin: false)
        nutritionPlanVC.loadViewIfNeeded()
    }
    
    func addShowTrainingPlanVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        trainingPlanListShow = storyboard.instantiateViewController(withIdentifier: "ShowPlanVC") as? ShowPlanViewController
        trainingPlanListShow.user = User(uid: self.trainer[0].uid, full_name: "Vuk Vukasinovic", email: self.trainer[0].email, profile_picture: "https://firebasestorage.googleapis.com/v0/b/fitty-de298.appspot.com/o/profile_picture%2F1k940WII11SjWKJmfRnQuFCJ2L83%2F1k940WII11SjWKJmfRnQuFCJ2L83.png?alt=media&token=b262aed2-8b48-45bf-b119-2816b6699acc", admin: true)
        trainingPlanListShow.dayUID = 1
        trainingPlanListShow.weekUID = 1
    }
    
    func addShowNutritionPlanVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        nutritionPlanListShow = storyboard.instantiateViewController(withIdentifier: "ShowNutritionPlanVC") as? ShowNutritionPlanViewController
        nutritionPlanListShow.user = User(uid: self.trainer[0].uid, full_name: "Vuk Vukasinovic", email: self.trainer[0].email, profile_picture: "https://firebasestorage.googleapis.com/v0/b/fitty-de298.appspot.com/o/profile_picture%2F1k940WII11SjWKJmfRnQuFCJ2L83%2F1k940WII11SjWKJmfRnQuFCJ2L83.png?alt=media&token=b262aed2-8b48-45bf-b119-2816b6699acc", admin: true)
        nutritionPlanListShow.dayUID = 1
        nutritionPlanListShow.weekUID = 1
    }
    
    func testTrainingPlanCountForUser(){
        let expectation = self.expectation(description: "testTrainingPlanForUser")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        let randomUser = self.user.randomElement()!
        
        Auth.auth().signIn(withEmail: randomUser.email, password: randomUser.password) { (_, _) in
            
            self.addTrainingPlanListVC()
            self.trainingPlanListVC.hasTheFunctionCalled = true
            self.trainingPlanListVC.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                let tableView = self.trainingPlanListVC.tableView
                
                if randomUser.uid == "w42mJrNUNsNqKRuCwf2xM3gKidV2" {
                    XCTAssertEqual(tableView?.visibleCells.count, 1)
                }
                else if randomUser.uid == "VNNBq5MHyccMZ9fCeA1wq34lBB43" {
                    XCTAssertEqual(tableView?.visibleCells.count, 0)
                }
                expectation.fulfill()
            })
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testNutritionPlanCountForUser(){
        let expectation = self.expectation(description: "testNutritionPlanCountForUser")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        let randomUser = self.user.randomElement()!
        
        Auth.auth().signIn(withEmail: randomUser.email, password: randomUser.password) { (_, _) in
            
            self.addNutritionPlanListVC()
            self.nutritionPlanListVC.hasTheFunctionCalled = true
            self.nutritionPlanListVC.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                let tableView = self.nutritionPlanListVC.tableView
                
                if randomUser.uid == "w42mJrNUNsNqKRuCwf2xM3gKidV2" {
                    XCTAssertEqual(tableView?.visibleCells.count, 1)
                }
                else if randomUser.uid == "VNNBq5MHyccMZ9fCeA1wq34lBB43" {
                    XCTAssertEqual(tableView?.visibleCells.count, 0)
                }
                expectation.fulfill()
            })
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testWeeklyTrainingPlanForUser() {
        let expectation = self.expectation(description: "testWeeklyTrainingPlanForUser")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        let randomUser = self.user.randomElement()!
        
        Auth.auth().signIn(withEmail: randomUser.email, password: randomUser.password) { (_, _) in

            self.addTrainingPlanListVC()
            self.trainingPlanListVC.hasTheFunctionCalled = true
            self.trainingPlanListVC.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let tableView = self.trainingPlanListVC.tableView
                
                for cells in tableView!.visibleCells where cells.viewWithTag(33) != nil && tableView?.visibleCells.count != 0 {
                    let cell = cells as! TrainingPlanListCell
                    let collectionView = cells.viewWithTag(33) as! UICollectionView
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        cells.awakeFromNib()
                        if randomUser.uid == "w42mJrNUNsNqKRuCwf2xM3gKidV2" {
                            XCTAssertEqual(cell.collectionView(collectionView, numberOfItemsInSection: 0), 2)
                        }
                        expectation.fulfill()
                    }
                }
                if randomUser.uid == "VNNBq5MHyccMZ9fCeA1wq34lBB43" {
                    XCTAssertEqual(tableView!.visibleCells.count, 0)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testWeeklyNutritionPlanForUser() {
        let expectation = self.expectation(description: "testWeeklyNutritionPlanForUser")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        let randomUser = self.user.randomElement()!
        
        Auth.auth().signIn(withEmail: randomUser.email, password: randomUser.password) { (_, _) in
            
            self.addNutritionPlanListVC()
            self.nutritionPlanListVC.hasTheFunctionCalled = true
            self.nutritionPlanListVC.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let tableView = self.nutritionPlanListVC.tableView
                
                for cells in tableView!.visibleCells where cells.viewWithTag(33) != nil && tableView?.visibleCells.count != 0  {
                    let cell = cells as! NutritionPlanListCell
                    let collectionView = cells.viewWithTag(33) as! UICollectionView
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        cells.awakeFromNib()
                        if randomUser.uid == "w42mJrNUNsNqKRuCwf2xM3gKidV2" {
                            XCTAssertEqual(cell.collectionView(collectionView, numberOfItemsInSection: 0), 2)
                        }
                        expectation.fulfill()
                    }
                }
                 if randomUser.uid == "VNNBq5MHyccMZ9fCeA1wq34lBB43" {
                    XCTAssertEqual(tableView?.visibleCells.count, 0)
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 20)
    }
    
    func testWeeklyTrainingPlanCheck() {
        let expectation = self.expectation(description: "testWeeklyTrainingPlanCheck")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: user[0].email, password: user[0].password) { (_, _) in
            
            self.addTrainingPlanListVC()
            self.trainingPlanListVC.hasTheFunctionCalled = true
            self.trainingPlanListVC.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let tableView = self.trainingPlanListVC.tableView
                
                for cells in tableView!.visibleCells where cells.viewWithTag(33) != nil {
                    let cell = cells as! TrainingPlanListCell
                    let collectionView = cells.viewWithTag(33) as! UICollectionView
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        cells.awakeFromNib()
                        let cellCollectionView = cell.collectionView(collectionView, cellForItemAt: [0,0]) as! WeekCell
                        XCTAssertTrue(cellCollectionView.checkButtonLabel.isHidden)
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testWeeklyNutritionPlanTrainerName() {
        let expectation = self.expectation(description: "testWeeklyNutritionPlanTrainerName")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: user[0].email, password: user[0].password) { (_, _) in
            
            self.addNutritionPlanListVC()
            self.nutritionPlanListVC.hasTheFunctionCalled = true
            self.nutritionPlanListVC.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let tableView = self.nutritionPlanListVC.tableView
                
                for cells in tableView!.visibleCells where cells.viewWithTag(33) != nil {
                    let cell = cells as! NutritionPlanListCell
                    let collectionView = cells.viewWithTag(33) as! UICollectionView
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        cells.awakeFromNib()
                        let cellCollectionView = cell.collectionView(collectionView, cellForItemAt: [0,0]) as! NutritionWeekCell
                        XCTAssertEqual(cellCollectionView.fullNameLabel.text, "Vuk Vukasinovic")
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testWeeklyTrainingPlanExerciseName() {
        let expectation = self.expectation(description: "testWeeklyTrainingPlanExerciseName")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: user[0].email, password: user[0].password) { (_, _) in
            
            self.addShowTrainingPlanVC()
            self.trainingPlanListShow.weekData = true
            self.trainingPlanListShow.loadViewIfNeeded()
            self.trainingPlanListShow.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let tableView = self.trainingPlanListShow.tableView
                
                let cellRow1 = tableView?.cellForRow(at: [0,0]) as! ShowPlanCell
                XCTAssertEqual(cellRow1.exerciseTextField.text, "Vezba 1")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testWeeklyNutritionPlanExerciseName() {
        let expectation = self.expectation(description: "testWeeklyNutritionPlanExerciseName")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: user[0].email, password: user[0].password) { (_, _) in
            
            self.addShowNutritionPlanVC()
            self.nutritionPlanListShow.weekData = true
            self.nutritionPlanListShow.loadViewIfNeeded()
            self.nutritionPlanListShow.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let tableView = self.nutritionPlanListShow.tableView
                
                let cellRow1 = tableView?.cellForRow(at: [0,0]) as! ShowNutritionPlanCell
                XCTAssertEqual(cellRow1.mealNameLabel.text, "Meal 1")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testCompleteTrainingPlanExerciseName() {
        let expectation = self.expectation(description: "testWeeklyTrainingPlanExerciseName")
        expectation.expectedFulfillmentCount = 2
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: user[0].email, password: user[0].password) { (_, _) in
            
            self.addShowTrainingPlanVC()
            self.trainingPlanListShow.weekData = false
            self.trainingPlanListShow.loadViewIfNeeded()
            self.trainingPlanListShow.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let tableView = self.trainingPlanListShow.tableView
                
                let cellRow1 = tableView?.cellForRow(at: [0,0]) as! ShowPlanCell
                XCTAssertEqual(cellRow1.exerciseTextField.text, "Vezba 1")
                expectation.fulfill()
                
                let cellRow2 = tableView?.cellForRow(at: [1,0]) as! ShowPlanCell
                cellRow2.awakeFromNib()
                XCTAssertEqual(cellRow2.exerciseTextField.text!, "Vezba 2")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testCompleteNutritionPlanExerciseName() {
        let expectation = self.expectation(description: "testCompleteNutritionPlanExerciseName")
        expectation.expectedFulfillmentCount = 2
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: user[0].email, password: user[0].password) { (_, _) in
            
            self.addShowNutritionPlanVC()
            self.nutritionPlanListShow.weekData = false
            self.nutritionPlanListShow.loadViewIfNeeded()
            self.nutritionPlanListShow.viewDidLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let tableView = self.nutritionPlanListShow.tableView
                
                let cellRow1 = tableView?.cellForRow(at: [0,0]) as! ShowNutritionPlanCell
                XCTAssertEqual(cellRow1.mealNameLabel.text, "Meal 1")
                expectation.fulfill()
                
                let cellRow2 = tableView?.cellForRow(at: [1,0]) as! ShowNutritionPlanCell
                cellRow2.awakeFromNib()
                XCTAssertEqual(cellRow2.mealNameLabel.text!, "Meal 2")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testClientsInfo() {
        let expectation = self.expectation(description: "testClientsInfo")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Auth.auth().signIn(withEmail: self.trainer[0].email, password: self.trainer[0].password) { [unowned self] (_, _) in
            
            self.addClientsVC()
            self.clientsVC.viewWillAppear(true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                let tableView = self.clientsVC.tableView
                tableView?.delegate?.tableView?(tableView!, didSelectRowAt: [0,0])
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    self.addClientsInfoVC()
                    self.clientsInfoVC.user = self.clientsVC.selectedUser!
                    self.clientsInfoVC.userInfo = self.clientsVC.selectedUserInfo!
                    self.clientsInfoVC.viewDidLoad()
                    XCTAssertEqual(self.clientsInfoVC.fullNameLabel.text, "Filip Popovic")
                    XCTAssertEqual(self.clientsInfoVC.heightLabel.text, "1.91")
                    XCTAssertEqual(self.clientsInfoVC.birthDateLabel.text, "02/27/1991")
                    expectation.fulfill()
                }
            }
        }
        }
        wait(for: [expectation], timeout: 20)
    }
    
    func testClientsTrainingPlan() {
        let expectation = self.expectation(description: "testClientsTrainingPlan")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: trainer[0].email, password: trainer[0].password) { (_, _) in
            
            self.addClientsVC()
            self.clientsVC.viewWillAppear(true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let tableView = self.clientsVC.tableView
                tableView?.delegate?.tableView?(tableView!, didSelectRowAt: [0,0])
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.addClientsInfoVC()
                    self.clientsInfoVC.user = self.clientsVC.selectedUser!
                    self.clientsInfoVC.userInfo = self.clientsVC.selectedUserInfo!
                    self.clientsInfoVC.viewDidLoad()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        self.addTrainingPlanVC()
                        self.trainingPlanVC.viewDidLoad()
                        
                        let tableView = self.trainingPlanVC.tableView
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                            XCTAssertEqual(tableView?.dataSource?.numberOfSections?(in: tableView!), 8)
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testClientsNutritionPlan() {
        let expectation = self.expectation(description: "testClientsNutritionPlan")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: trainer[0].email, password: trainer[0].password) { (_, _) in
            
            self.addClientsVC()
            self.clientsVC.viewWillAppear(true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let tableView = self.clientsVC.tableView
                tableView?.delegate?.tableView?(tableView!, didSelectRowAt: [0,0])
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.addClientsInfoVC()
                    self.clientsInfoVC.user = self.clientsVC.selectedUser!
                    self.clientsInfoVC.userInfo = self.clientsVC.selectedUserInfo!
                    self.clientsInfoVC.viewDidLoad()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                        self.addNutritionPlanVC()
                        self.nutritionPlanVC.viewDidLoad()
                        
                        let tableView = self.nutritionPlanVC.tableView
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                            XCTAssertEqual(tableView?.dataSource?.numberOfSections?(in: tableView!), 4)
                            expectation.fulfill()
                        }
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 30)
    }
    
    func testClientsInfoEmpty() {
        let expectation = self.expectation(description: "testClientsInfoEmpty")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        Auth.auth().signIn(withEmail: trainer[1].email, password: trainer[1].password) { (_, _) in
            
            self.addClientsVC()
            self.clientsVC.viewWillAppear(true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let tableView = self.clientsVC.tableView
                XCTAssertNil(tableView?.cellForRow(at: [0,0]))
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    static var allTests: [(String, (TrainingAndNutritionPlanTests) -> () throws -> Void)] {
        return [
            ("testTrainingPlanCountForUser", testTrainingPlanCountForUser),
            ("testNutritionPlanCountForUser", testNutritionPlanCountForUser),
            ("testWeeklyTrainingPlanForUser", testWeeklyTrainingPlanForUser),
            ("testWeeklyNutritionPlanForUser", testWeeklyNutritionPlanForUser),
            ("testWeeklyTrainingPlanCheck", testWeeklyTrainingPlanCheck),
            ("testWeeklyNutritionPlanTrainerName", testWeeklyNutritionPlanTrainerName),
            ("testWeeklyTrainingPlanExerciseName", testWeeklyTrainingPlanExerciseName),
            ("testWeeklyNutritionPlanExerciseName", testWeeklyNutritionPlanExerciseName),
            ("testCompleteTrainingPlanExerciseName", testCompleteTrainingPlanExerciseName),
            ("testCompleteNutritionPlanExerciseName", testCompleteNutritionPlanExerciseName),
            ("testClientsInfo", testClientsInfo),
            ("testClientsTrainingPlan", testClientsTrainingPlan),
            ("testClientsNutritionPlan", testClientsNutritionPlan),
            ("testClientsInfoEmpty", testClientsInfoEmpty)
        ]
    }
    
    
    
}
