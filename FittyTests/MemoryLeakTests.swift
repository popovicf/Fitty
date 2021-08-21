//
//  MemoryLeakTests.swift
//  FittyTests
//
//  Created by Filip Popovic
//

import Firebase
import XCTest
@testable import Fitty

class MemoryLeakTests: XCTestCase {
    
    var user: (email: String, password: String, uid: String)?
    var trainer: (email: String, password: String, uid: String)?
    
    override func setUpWithError() throws {
        user = ( email: "filip@filip.com", password: "filipfilip", uid: "w42mJrNUNsNqKRuCwf2xM3gKidV2")
        trainer = ( email: "vuk@vuk.com", password: "filipfilip", uid: "1k940WII11SjWKJmfRnQuFCJ2L83")
    }
    
    override func tearDownWithError() throws {
        try Auth.auth().signOut()
    }
    
    override func setUp() {
        super.setUp()
        try! Auth.auth().signOut()
        user = ( email: "filip@filip.com", password: "filipfilip", uid: "w42mJrNUNsNqKRuCwf2xM3gKidV2")
        trainer = ( email: "vuk@vuk.com", password: "filipfilip", uid: "1k940WII11SjWKJmfRnQuFCJ2L83")
    }
    
    override func tearDown() {
        try! Auth.auth().signOut()
        super.tearDown()
    }
    
    func testNutritionPlanListCellSelectionDelegateNotRetained() {
        let expectation = self.expectation(description: "testNutritionPlanListCellSelectionDelegateNotRetained")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        let controller = NutritionPlanListCell()
        
        var delegate = NutritionPlanListViewController()
        controller.delegate = delegate
        
        delegate = NutritionPlanListViewController()
        expectation.fulfill()
        wait(for: [expectation], timeout: 10)
        XCTAssertNil(controller.delegate)
    }
    
    func testTrainingPlanListCellSelectionDelegateNotRetained() {
        let expectation = self.expectation(description: "testTrainingPlanListCellSelectionDelegateNotRetained")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        let controller = TrainingPlanListCell()
        
        var delegate = TrainingPlanListViewController()
        controller.delegate = delegate
        
        delegate = TrainingPlanListViewController()
        expectation.fulfill()
        wait(for: [expectation], timeout: 10)
        XCTAssertNil(controller.delegate)
    }
    
    func testFindTrainerCellDelegateNotRetained() {
        let expectation = self.expectation(description: "testFindTrainerCellDelegateNotRetained")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        let controller = FindTrainerCell()
        
        var delegate = FindTrainerViewController()
        controller.delegate = delegate
        
        delegate = FindTrainerViewController()
        expectation.fulfill()
        wait(for: [expectation], timeout: 10)
        XCTAssertNil(controller.delegate)
    }
    
    func testGetUserTrainingPlanCompletionHandlersRemoved() {
        let expectation = self.expectation(description: "testGetUserTrainingPlanCompletionHandlersRemoved")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        let service = FirebaseService()
        var object = NSObject()
        weak var weakObject = object
        
        Auth.auth().signIn(withEmail: user!.email, password: user!.password) { (res, error) in
            service.getUserTrainingPlan(trainer_uid: self.trainer!.uid) { [object] (plan) in
                _ = object
                expectation.fulfill()
            } daysArray: { (_) in } weeksArray: { (_) in } exercise_uids: { (_) in }
        }
        
        object = NSObject()
        wait(for: [expectation], timeout: 10)
        XCTAssertNil(weakObject)
    }
    
    func testLoginCompletionHandlersRemoved() {
        let expectation = self.expectation(description: "testLoginCompletionHandlersRemoved")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        var object = NSObject()
        weak var weakObject = object
        
        Auth.auth().signIn(withEmail: user!.email, password: user!.password) { [object] (_, _) in
            _ = object
            expectation.fulfill()
        }
        
        object = NSObject()
        wait(for: [expectation], timeout: 10)
        XCTAssertNil(weakObject)
    }
    
    static var allTests: [(String, (MemoryLeakTests) -> () throws -> Void)] {
        return [
            ("testNutritionPlanListCellSelectionDelegateNotRetained", testNutritionPlanListCellSelectionDelegateNotRetained),
            ("testTrainingPlanListCellSelectionDelegateNotRetained", testTrainingPlanListCellSelectionDelegateNotRetained),
            ("testFindTrainerCellDelegateNotRetained", testFindTrainerCellDelegateNotRetained),
            ("testGetUserTrainingPlanCompletionHandlersRemoved", testGetUserTrainingPlanCompletionHandlersRemoved),
            ("testLoginCompletionHandlersRemoved", testLoginCompletionHandlersRemoved)
        ]
    }
}
