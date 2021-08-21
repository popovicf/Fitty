//
//  ProfileUITests.swift
//  FittyUITests
//
//  Created by Filip Popovic
//

import XCTest

class ProfileUITests: XCTestCase {

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
    
    func testUserChangeFullName() {
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        let button = app.children(matching: .window).buttons.matching(identifier: "pencil.circle.fill").element(boundBy: 0)
        _ = button.waitForExistence(timeout: 10)
        button.tap()
        
        XCTAssertTrue(button.exists)
        
        var didShowDialog = false
        expectation(for: NSPredicate() {(_,_) in
            self.app.tap()
            return didShowDialog
        }, evaluatedWith: NSNull(), handler: nil)
        
        addUIInterruptionMonitor(withDescription: "Change fullname") { (alert) -> Bool in
            alert.textFields.element(boundBy: 0).tap()
            alert.textFields.element(boundBy: 0).typeText("Filip Popovic")
            self.app.alerts["Message"].scrollViews.otherElements.buttons["Update"].tap()
            
            XCTAssertTrue(self.app.staticTexts["Filip Popovic"].exists)
            
            self.app.tabBars["Tab Bar"].buttons["Home"].tap()
            
            didShowDialog = true
            return true
        }
        
        waitForExpectations(timeout: 20)
    }
    
    func testUserChangeEmail() {
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        let button = app.children(matching: .window).buttons.matching(identifier: "pencil.circle.fill").element(boundBy: 1)
        _ = button.waitForExistence(timeout: 10)
        button.tap()
        
        XCTAssertTrue(button.exists)
        
        var didShowDialog = false
        expectation(for: NSPredicate() {(_,_) in
            self.app.tap()
            return didShowDialog
        }, evaluatedWith: NSNull(), handler: nil)
        
        addUIInterruptionMonitor(withDescription: "Change email") { (alert) -> Bool in
            alert.textFields.element(boundBy: 0).tap()
            alert.textFields.element(boundBy: 0).typeText("popovic.filip91@gmail.com")
            self.app.alerts["Message"].scrollViews.otherElements.buttons["Update"].tap()
            
            XCTAssertTrue(self.app.staticTexts["popovic.filip91@gmail.com"].exists)
            
            self.app.tabBars["Tab Bar"].buttons["Home"].tap()
            
            didShowDialog = true
            return true
        }
        
        waitForExpectations(timeout: 20)
    }
    
    func testTrainerChangeFullName() {
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
        
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        let button = app.children(matching: .window).buttons.matching(identifier: "pencil.circle.fill").element(boundBy: 0)
        _ = button.waitForExistence(timeout: 10)
        button.tap()
        
        XCTAssertTrue(button.exists)
        
        var didShowDialog = false
        expectation(for: NSPredicate() {(_,_) in
            self.app.tap()
            return didShowDialog
        }, evaluatedWith: NSNull(), handler: nil)
        
        addUIInterruptionMonitor(withDescription: "Change fullname") { (alert) -> Bool in
            alert.textFields.element(boundBy: 0).tap()
            alert.textFields.element(boundBy: 0).typeText("Vuk Vukasinovic")
            self.app.alerts["Message"].scrollViews.otherElements.buttons["Update"].tap()
            
            XCTAssertTrue(self.app.staticTexts["Vuk Vukasinovic"].exists)
            
            self.app.tabBars["Tab Bar"].buttons["Home"].tap()
            
            didShowDialog = true
            return true
        }
        
        waitForExpectations(timeout: 20)
    }
    
    func testTrainerChangeEmail() {
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
        
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        let button = app.children(matching: .window).buttons.matching(identifier: "pencil.circle.fill").element(boundBy: 1)
        _ = button.waitForExistence(timeout: 10)
        button.tap()
        
        XCTAssertTrue(button.exists)
        
        var didShowDialog = false
        expectation(for: NSPredicate() {(_,_) in
            self.app.tap()
            return didShowDialog
        }, evaluatedWith: NSNull(), handler: nil)
        
        addUIInterruptionMonitor(withDescription: "Change email") { (alert) -> Bool in
            alert.textFields.element(boundBy: 0).tap()
            alert.textFields.element(boundBy: 0).typeText("vuk@vuk.com")
            self.app.alerts["Message"].scrollViews.otherElements.buttons["Update"].tap()
            
            XCTAssertTrue(self.app.staticTexts["vuk@vuk.com"].exists)
            
            self.app.tabBars["Tab Bar"].buttons["Home"].tap()
            
            didShowDialog = true
            return true
        }
        
        waitForExpectations(timeout: 20)
    }
}
