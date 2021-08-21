//
//  TrainingPlanUITests.swift
//  FittyUITests
//
//  Created by Filip Popovic
//

import XCTest
@testable import Fitty

class TrainingPlanUITests: XCTestCase {
    
    var app: XCUIApplication!
    var user: [(email: String, password: String, uid: String)] = []
    var trainer: [(email: String, password: String, uid: String)] = []
    
    override func setUpWithError() throws {
        user = [
            (email: "filip@filip.com", password: "filipfilip", uid: "w42mJrNUNsNqKRuCwf2xM3gKidV2"),
            (email: "marko@marko.com", password: "filipfilip", uid: "VNNBq5MHyccMZ9fCeA1wq34lBB43")
        ]
        
        trainer = [
            (email: "vuk@vuk.com", password: "filipfilip", uid: "1k940WII11SjWKJmfRnQuFCJ2L83"),
            (email: "bojan@bojan.com", password: "filipfilip", uid: "6fkecr8oOxdhgY9v6TMWMAKcXp52")
        ]
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func setUp() {
        app.staticTexts["Continue with Facebook"].tap()
        var didShowDialog = false
        expectation(for: NSPredicate() {(_,_) in
            self.app.tap()
            return didShowDialog
        }, evaluatedWith: NSNull(), handler: nil)
        
        addUIInterruptionMonitor(withDescription: "Facebook Login") { (alert) -> Bool in
            alert.buttons.element(boundBy: 1).tap()
            self.app.webViews.webViews.webViews.buttons["Настави"].tap()
            
            _ = self.app.tabBars["Tab Bar"].waitForExistence(timeout: 5)
            XCTAssertTrue(self.app.tabBars["Tab Bar"].exists)
            
            didShowDialog = true
            return true
        }
        
        waitForExpectations(timeout: 10)
    }
    
    override func tearDownWithError() throws {
        _ = app.wait(for: .runningForeground, timeout: 20)
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        app.children(matching: .window).element(boundBy: 0).buttons["Log out"].tap()
    }
    
    func testTrainingPlanComplete() {
        _ = app.wait(for: .runningForeground, timeout: 10)
        app.tabBars["Tab Bar"].buttons["Training"].tap()
        let tablesQuery = app.tables
        let vukVukasinovicCellsQuery = tablesQuery.cells.containing(.staticText, identifier:"Vuk Vukasinovic")
        vukVukasinovicCellsQuery.staticTexts["See complete plan"].tap()
        
        XCTAssertEqual(tablesQuery.children(matching: .cell).element(boundBy: 0).children(matching: .textField).element(boundBy: 0).value as! String, "Vezba 1")
    }
    
    func testTrainingPlanWeek() {
        _ = app.wait(for: .runningForeground, timeout: 10)
        app.tabBars["Tab Bar"].buttons["Training"].tap()
        let tablesQuery = app.tables
        let vukVukasinovicCellsQuery = tablesQuery.cells.containing(.staticText, identifier:"Vuk Vukasinovic")
        vukVukasinovicCellsQuery.staticTexts["Week 01 - Day 01"].tap()
        
        XCTAssertEqual(tablesQuery.children(matching: .cell).element(boundBy: 0).children(matching: .textField).element(boundBy: 0).value as! String, "Vezba 1")
    }
    
    func testTrainingPlanWeeksLabel() {
        _ = app.wait(for: .runningForeground, timeout: 10)
        app.tabBars["Tab Bar"].buttons["Training"].tap()
        let tablesQuery = app.tables
        let vukVukasinovicCellsQuery = tablesQuery.cells.containing(.staticText, identifier:"Vuk Vukasinovic").staticTexts["1 week plan"].waitForExistence(timeout: 5)
        
        XCTAssertTrue(vukVukasinovicCellsQuery)
    }
    
    func testCreateNutritionPlan() {
        _ = app.wait(for: .runningForeground, timeout: 10)
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        app.children(matching: .window).element(boundBy: 0).buttons["Log out"].tap()
        
        _ = app.wait(for: .runningForeground, timeout: 10)
        let credentials = trainer[0]
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials.email)
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials.password)
        app.staticTexts["Log in"].tap()
        _ = app.tabBars["Tab Bar"].waitForExistence(timeout: 5)
        
        XCTAssertTrue(app.tabBars["Tab Bar"].exists)
        
        app.tabBars["Tab Bar"].buttons["Clients"].tap()
        app.tables.cells.containing(.staticText, identifier: "Filip Popovic").element.tap()
        app.buttons["Create Training Plan"].tap()
        XCTAssertTrue(app.tables.cells.element.exists)
    }
}
