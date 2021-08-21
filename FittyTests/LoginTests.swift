//
//  LoginTests.swift
//  FittyTests
//
//  Created by Filip Popovic
//

import XCTest
import Firebase
@testable import Fitty

class LoginTests: XCTestCase {
    
    var loginForm: LoginFormViewController!
    var validTestCases:[(email: String, password: String)] = []
    var invalidTestCases:[(email: String, password: String)] = []
    var invalidParamsTestCases:[(email: String, password: String)] = []
    var isLoggedIn = false
    
    override func setUpWithError() throws {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        loginForm = storyboard.instantiateViewController(withIdentifier: "LoginFormVC") as? LoginFormViewController
        loginForm.loadViewIfNeeded()
    }
    
    override func tearDownWithError() throws {
        loginForm = nil
        isLoggedIn = false
        try Auth.auth().signOut()
    }
    
    override func setUp() {
        super.setUp()
        try! Auth.auth().signOut()
        validTestCases = [
            (email: "filip@filip.com", password: "filipfilip"),
            (email: "vuk@vuk.com", password: "filipfilip"),
            (email: "marko@marko.com", password: "filipfilip")
        ]
        
        invalidTestCases = [
            (email: "user@user.com", password: "pass123"),
            (email: "admin@admin.com", password: "admin123"),
            (email: "test@test.com", password: "Met123@")
        ]
        
        invalidParamsTestCases = [
            (email: "abcbac.com", password: "abc123"),
            (email: "abc@abccom", password: "Met123@"),
            (email: "abc@abc.com", password: "123"),
            (email: "", password: "")
        ]
    }
    
    override func tearDown() {
        loginForm = nil
        isLoggedIn = false
        try! Auth.auth().signOut()
        super.tearDown()
    }
    
    func testLoginSuccess() throws {
        let longRunningExpectation = self.expectation(description: "LoginSuccess")
        longRunningExpectation.expectedFulfillmentCount = 3
        longRunningExpectation.assertForOverFulfill = true        
        
        for valid in self.validTestCases {
            Auth.auth().signIn(withEmail: valid.email, password: valid.password) { (res, error) in
                if let _ = error {
                    self.isLoggedIn = false
                } else {
                    self.isLoggedIn = true
                }
                longRunningExpectation.fulfill()
            }
        }
                
        wait(for: [longRunningExpectation], timeout: 1)
        XCTAssertTrue(self.isLoggedIn)
    }
    
    func testLoginFail() throws {
        let longRunningExpectation = expectation(description: "LoginFail")
        longRunningExpectation.expectedFulfillmentCount = 3
        longRunningExpectation.assertForOverFulfill = true
        
        for invalid in self.invalidTestCases {
            Auth.auth().signIn(withEmail: invalid.email, password: invalid.password) { (res, error) in
                if let _ = error {
                    self.isLoggedIn = false
                } else {
                    self.isLoggedIn = true
                }
                longRunningExpectation.fulfill()
            }
        }
        
        wait(for: [longRunningExpectation], timeout: 1)
        XCTAssertFalse(self.isLoggedIn)
    }
    
    func testLoginInvalidParams() throws {
        let longRunningExpectation = expectation(description: "LoginInvalidParams")
        longRunningExpectation.expectedFulfillmentCount = 4
        longRunningExpectation.assertForOverFulfill = true
        
        for invalidParam in self.invalidParamsTestCases {
            Auth.auth().signIn(withEmail: invalidParam.email, password: invalidParam.password) { (res, error) in
                if let _ = error {
                    self.isLoggedIn = false
                } else {
                    self.isLoggedIn = true
                }
                longRunningExpectation.fulfill()
            }
        }
        
        wait(for: [longRunningExpectation], timeout: 1)
        XCTAssertFalse(self.isLoggedIn)
    }
    
    func testSignUpSuccess() throws {
        let longRunningExpectation = expectation(description: "SignUpSuccess")
        longRunningExpectation.expectedFulfillmentCount = 3
        longRunningExpectation.assertForOverFulfill = true
        
        for invalid in self.invalidTestCases {
            Auth.auth().createUser(withEmail: invalid.email, password: invalid.password) { (res, error) in
                if let _ = error {
                    self.isLoggedIn = false
                } else {
                    self.isLoggedIn = true
                }
                longRunningExpectation.fulfill()
            }
        }
        
        wait(for: [longRunningExpectation], timeout: 3)
        XCTAssertTrue(self.isLoggedIn)
    }
    
    func testSignUpFail() throws {
        let longRunningExpectation = expectation(description: "SignUpFail")
        longRunningExpectation.expectedFulfillmentCount = 3
        longRunningExpectation.assertForOverFulfill = true
        
        for valid in self.validTestCases {
            Auth.auth().createUser(withEmail: valid.email, password: valid.password) { (res, error) in
                if let _ = error {
                    self.isLoggedIn = false
                } else {
                    self.isLoggedIn = true
                }
                longRunningExpectation.fulfill()
            }
        }
        wait(for: [longRunningExpectation], timeout: 1)
        
        XCTAssertFalse(self.isLoggedIn)
    }
    
    func testSignUpInvalidParams() throws {
        let longRunningExpectation = expectation(description: "SignUpInvalidParams")
        longRunningExpectation.expectedFulfillmentCount = 4
        longRunningExpectation.assertForOverFulfill = true
        
        for invalid in self.invalidParamsTestCases {
            Auth.auth().createUser(withEmail: invalid.email, password: invalid.password) { (res, error) in
                if let _ = error {
                    self.isLoggedIn = false
                } else {
                    self.isLoggedIn = true
                }
                longRunningExpectation.fulfill()
            }
        }
        wait(for: [longRunningExpectation], timeout: 1)
        
        XCTAssertFalse(self.isLoggedIn)
    }
    
    func testFullnameTextFieldContentType() throws {
        let emailTextField = try XCTUnwrap(loginForm.fullNameTextField)
        
        XCTAssertEqual(emailTextField.textContentType, .name)
    }
    
    func testEmailTextFieldContentType() throws {
        let emailTextField = try XCTUnwrap(loginForm.emailTextField)
        
        XCTAssertEqual(emailTextField.textContentType, .emailAddress)
    }
    
    func testPasswordTextFieldContentType() throws {
        let passwordTextField = try XCTUnwrap(loginForm.passwordTextField)
        
        XCTAssertEqual(passwordTextField.textContentType, .password)
    }
    
    func testCheckTrainerContentType() throws {
        let trainerButton = try XCTUnwrap(loginForm.trainerButton)
        
        XCTAssertEqual(trainerButton.buttonType, .custom)
    }
    
    static var allTests: [(String, (LoginTests) -> () throws -> Void)] {
        return [
            ("testLoginSuccess", testLoginSuccess),
            ("testLoginFail", testLoginFail),
            ("testLoginInvalidParams", testLoginInvalidParams),
            ("testSignUpSuccess", testSignUpSuccess),
            ("testSignUpFail", testSignUpFail),
            ("testSignUpInvalidParams", testSignUpInvalidParams),
            ("testFullnameTextFieldContentType", testFullnameTextFieldContentType),
            ("testEmailTextFieldContentType", testEmailTextFieldContentType),
            ("testPasswordTextFieldContentType", testPasswordTextFieldContentType),
            ("testCheckTrainerContentType", testCheckTrainerContentType)
        ]
    }
    
}
