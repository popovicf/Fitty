//
//  LoginFormUITests.swift
//  FittyUITests
//
//  Created by Filip Popovic
//

import XCTest

class LoginFormUITests: XCTestCase {
    
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
        
        _ = app.wait(for: .runningForeground, timeout: 20)
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        app.children(matching: .window).element(boundBy: 0).buttons["Log out"].tap()
    }

    func testUserLogin() {
        _ = app.wait(for: .runningForeground, timeout: 10)
        let credentials = user.randomElement()
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials!.email)
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials!.password)
        app.staticTexts["Log in"].tap()
        _ = app.tabBars["Tab Bar"].waitForExistence(timeout: 5)
        
        XCTAssertTrue(app.tabBars["Tab Bar"].exists)
        
//        _ = app.wait(for: .runningForeground, timeout: 20)
//        app.tabBars["Tab Bar"].buttons["Profile"].tap()
//        app.children(matching: .window).element(boundBy: 0).buttons["Log out"].tap()
    }
    
    func testTrainerLogin() {
        _ = app.wait(for: .runningForeground, timeout: 10)
        let credentials = trainer.randomElement()
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText(credentials!.email)
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText(credentials!.password)
        app.staticTexts["Log in"].tap()
        _ = app.tabBars["Tab Bar"].waitForExistence(timeout: 5)
        
        XCTAssertTrue(app.tabBars["Tab Bar"].exists)
        
//        _ = app.wait(for: .runningForeground, timeout: 20)
//        app.tabBars["Tab Bar"].buttons["Profile"].tap()
//        app.children(matching: .window).element(boundBy: 0).buttons["Log out"].tap()
    }
    
    func testFacebookLogin() {
        app.staticTexts["Continue with Facebook"].tap()
        
        var didShowDialog = false
        expectation(for: NSPredicate() {(_,_) in
            self.app.tap()
            return didShowDialog
        }, evaluatedWith: NSNull(), handler: nil)

        addUIInterruptionMonitor(withDescription: "Facebook Login") { (alert) -> Bool in
            alert.buttons["Continue"].tap()
            self.app.webViews.webViews.webViews.buttons["Настави"].tap()
            
            _ = self.app.tabBars["Tab Bar"].waitForExistence(timeout: 5)
            XCTAssertTrue(self.app.tabBars["Tab Bar"].exists)
            
//            _ = self.app.wait(for: .runningForeground, timeout: 20)
//            self.app.tabBars["Tab Bar"].buttons["Profile"].tap()
//            self.app.children(matching: .window).element(boundBy: 0).buttons["Log out"].tap()
            
            didShowDialog = true
            return true
        }
        
        waitForExpectations(timeout: 20)
    }
    
    func testInvalidEmailFormat() {
        _ = app.wait(for: .runningForeground, timeout: 10)
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("testtest123")
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("testtest123")
        app.staticTexts["Log in"].tap()
        
        var didShowDialog = false
        expectation(for: NSPredicate() {(_,_) in
            self.app.tap()
            return didShowDialog
        }, evaluatedWith: NSNull(), handler: nil)

        addUIInterruptionMonitor(withDescription: "Invalid Email Login") { (alert) -> Bool in
            alert.buttons.element(boundBy: 0).tap()
            
            _ = self.app.tabBars["Tab Bar"].waitForExistence(timeout: 5)
            XCTAssertFalse(self.app.tabBars["Tab Bar"].exists)
            
            self.app.tap()
            self.app.textFields["Email"].tap()
            self.app.textFields["Email"].clearAndEnterText(text: "")
            
            self.app.secureTextFields["Password"].tap()
            self.app.secureTextFields["Password"].clearAndEnterText(text: "")
            self.testUserLogin()
            
            didShowDialog = true
            return true
        }
        waitForExpectations(timeout: 30)
    }
    
    func testSignUpNewUser() {
        _ = app.wait(for: .runningForeground, timeout: 10)

        app.buttons["Sign up"].tap()

        app.textFields["Full Name"].tap()
        app.textFields["Full Name"].typeText("Test123")
        app.buttons["Go"].tap()

        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("test123@test123.com")
        app.buttons["Go"].tap()

        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("test123")
        app.buttons["Go"].tap()

        app.staticTexts["Sign up"].tap()
        _ = app.staticTexts["CALCULATE YOUR BMI"].waitForExistence(timeout: 5)

        XCTAssertTrue(app.staticTexts["CALCULATE YOUR BMI"].exists)

        app.buttons["Calculate"].tap()
        app.buttons["Proceed"].tap()
        app.buttons["Save"].tap()

//        _ = app.wait(for: .runningForeground, timeout: 20)
//        app.tabBars["Tab Bar"].buttons["Profile"].tap()
//        app.children(matching: .window).element(boundBy: 0).buttons["Log out"].tap()
//        app.terminate()
    }

}
extension XCUIElement {
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        self.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}
