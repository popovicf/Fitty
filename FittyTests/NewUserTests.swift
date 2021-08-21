//
//  NewUserTests.swift
//  FittyTests
//
//  Created by Filip Popovic
//

import XCTest
import Firebase
@testable import Fitty

class NewUserTests: XCTestCase {
    
    var calculateVC: CalculateViewController!
    var resultsVC: ResultsViewController!
    var additionalVC: AdditionalInfoViewController!
    var validTestCases:[(email: String, password: String)] = []
    var invalidTestCases:[(email: String, password: String)] = []
    var selectedTestCases:(email: String, password: String)?
    
    override func setUpWithError() throws {
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
    }
    
    override func tearDownWithError() throws {
        calculateVC = nil
        try Auth.auth().signOut()
    }
    
    override func setUp() {
        super.setUp()
       // DispatchQueue.main.async {
            Auth.auth().signIn(withEmail: self.validTestCases.randomElement()!.email, password: self.validTestCases.randomElement()!.password) { (_, _) in
            }
       // }
    }
    
    override func tearDown() {
        calculateVC = nil
        additionalVC = nil
        try! Auth.auth().signOut()
        super.tearDown()
    }
    
    func addCalculateVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        calculateVC = storyboard.instantiateViewController(withIdentifier: "CalculateVC") as? CalculateViewController
        calculateVC.loadViewIfNeeded()
    }
    
    func addResultsVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        resultsVC = storyboard.instantiateViewController(withIdentifier: "ResultsVC") as? ResultsViewController
        resultsVC.loadViewIfNeeded()
    }
    
    func addAdditionalVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        additionalVC = storyboard.instantiateViewController(withIdentifier: "AdditionalInfoVC") as? AdditionalInfoViewController
        additionalVC.loadViewIfNeeded()
    }
    
    func testHeightSliderContentType() {
        addCalculateVC()
        let heightSlider = try! XCTUnwrap(calculateVC.heightSlider)
        XCTAssertEqual(heightSlider.contentMode, .scaleToFill)
    }
    
    func testWeightSliderContentType() {
        addCalculateVC()
        let weightSlider = try! XCTUnwrap(calculateVC.weightSlider)
        XCTAssertEqual(weightSlider.contentMode, .scaleToFill)
    }
    
    func testHeightLabel() {
        self.addCalculateVC()
        let heightLabel = try! XCTUnwrap(self.calculateVC.heightLabel)
        let heightSlider = try! XCTUnwrap(self.calculateVC.heightSlider)
        heightSlider.value = 1.98065
        calculateVC.heightSliderChanged(heightSlider)
        XCTAssertEqual(String(format: "%.2f", heightSlider.value) + "m", heightLabel.text!)
    }
    
    func testWeightLabel() {
        self.addCalculateVC()
        let weightLabel = try! XCTUnwrap(self.calculateVC.weightLabel)
        let weightSlider = try! XCTUnwrap(self.calculateVC.weightSlider)
        weightSlider.value = 89.98065
        calculateVC.weightSliderChanged(weightSlider)
        XCTAssertEqual(String(format: "%.0f", weightSlider.value) + "kg", weightLabel.text!)
    }
    
    func testCheckBMI() {
        let expectation = self.expectation(description: "testCheckBMI")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true
        
        var bmiCalculator = BMICalculator()
        self.addCalculateVC()
        let heightSlider = try! XCTUnwrap(self.calculateVC.heightSlider)
        heightSlider.value = 1.98065
        let weightSlider = try! XCTUnwrap(self.calculateVC.weightSlider)
        weightSlider.value = 89.98065
        bmiCalculator.calculateBMI(height: heightSlider.value, weight: weightSlider.value)
        
        self.addResultsVC()
        resultsVC.bmiValue = Float(bmiCalculator.getBMI()["bmiValue"] ?? "")
        resultsVC.adviceValue = bmiCalculator.getBMI()["bmiAdvice"] ?? ""
        resultsVC.view.backgroundColor = bmiCalculator.getBMIColor()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.resultsVC.viewDidLoad()
            let bmi = bmiCalculator.getBMI()
            let adviceLabel = try! XCTUnwrap(self.resultsVC.adviceLabel)
            let bmiValue = try! XCTUnwrap(self.resultsVC.bmiLabel)
            print(String(format: "%.1f", Float(bmi["bmiValue"] ?? "")!))
            
            XCTAssertEqual(adviceLabel.text!, bmi["bmiAdvice"]!)
            XCTAssertEqual(bmiValue.text!, String(format: "%.1f", Float(bmi["bmiValue"] ?? "")!))
            XCTAssertEqual(self.resultsVC.view.backgroundColor, bmiCalculator.getBMIColor())
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testAdditionalVCTypeCheck() {
        addAdditionalVC()
        
        let birthDateTextField = try! XCTUnwrap(self.additionalVC.birthDateTextField)
        XCTAssertEqual(birthDateTextField.textContentType, .none)
        let birthDateInputViewType = String("\(birthDateTextField.inputView!)").split(separator: ":").first!.dropFirst()
        XCTAssertEqual(birthDateInputViewType, "UIDatePicker")
        
        let genderTextField = try! XCTUnwrap(self.additionalVC.genderTextField)
        XCTAssertEqual(genderTextField.textContentType, .none)
        let genderInputViewType = String("\(genderTextField.inputView!)").split(separator: ":").first!.dropFirst()
        XCTAssertEqual(genderInputViewType, "UIPickerView")
        
        let prevActivity = try! XCTUnwrap(self.additionalVC.previousActivityTextField)
        XCTAssertEqual(prevActivity.textContentType, .none)
        let prevActivityInputViewType = String("\(prevActivity.inputView!)").split(separator: ":").first!.dropFirst()
        XCTAssertEqual(prevActivityInputViewType, "UIPickerView")
        
        let injuries = try! XCTUnwrap(self.additionalVC.injuriesTextField)
        XCTAssertEqual(injuries.textContentType, .none)
        XCTAssertEqual(injuries.inputView, nil)
        
        let chronicDiseasses = try! XCTUnwrap(self.additionalVC.chronicDiseasesTextField)
        XCTAssertEqual(chronicDiseasses.textContentType, .none)
        XCTAssertEqual(chronicDiseasses.inputView, nil)
        
        let physicalCondition = try! XCTUnwrap(self.additionalVC.physicalConditionTextField)
        XCTAssertEqual(physicalCondition.textContentType, .none)
        let physicalConditionInputViewType = String("\(physicalCondition.inputView!)").split(separator: ":").first!.dropFirst()
        XCTAssertEqual(physicalConditionInputViewType, "UIPickerView")
    }
    
    static var allTests: [(String, (NewUserTests) -> () throws -> Void)] {
        return [
            ("testHeightSliderContentType", testHeightSliderContentType),
            ("testWeightSliderContentType", testWeightSliderContentType),
            ("testHeightLabel", testHeightLabel),
            ("testWeightLabel", testWeightLabel),
            ("testCheckBMI", testCheckBMI),
            ("testAdditionalVCTypeCheck", testAdditionalVCTypeCheck)
        ]
    }
    
}
