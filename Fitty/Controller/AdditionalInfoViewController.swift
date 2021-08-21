//
//  AdditionalInfoViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase

class AdditionalInfoViewController: UIViewController {
    
    @IBOutlet weak var birthDateTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var previousActivityTextField: UITextField!
    @IBOutlet weak var injuriesTextField: UITextField!
    @IBOutlet weak var chronicDiseasesTextField: UITextField!
    @IBOutlet weak var physicalConditionTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    let datePicker = UIDatePicker()
    let gender = UIPickerView()
    let previousActivity = UIPickerView()
    let physicalCondition = UIPickerView()
    let genderList = ["Male", "Female"]
    let previousActivityList = ["No fitness experience", "Occasional activity", "Amateur athlete", "Profesional athlete", "Ex athlete"]
    let physicalConditionList = ["One month without any activity", "No activity for last 3 months", "Inactive for about 6 months period", "2-3 times a week activity", "3-5 times a week activity", "Everyday activity"]
    let firbaseService = FirebaseService()
    var dbData = User.userInstance
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .systemOrange
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemOrange]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Additional Information" 
        setBirthDate()
        setGender()
        setInjuries()
        setChronicDiseases()
        setPreviousActivity()
        setPhysicalCondition()
        saveButton.layer.cornerRadius = 20
    }
    
    func setBirthDate() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressedBirth))
        toolbar.setItems([doneButton], animated: true)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.frame = CGRect(x: view.center.x, y: view.center.y, width: 400, height: 400)
        datePicker.tag = 17
        birthDateTextField.inputAccessoryView = toolbar
        birthDateTextField.inputView = datePicker
    }
    
    @objc func doneButtonPressedBirth() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "MM/dd/YYYY"
        birthDateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func setGender() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressed))
        toolbar.setItems([doneButton], animated: true)
        gender.delegate = self
        genderTextField.inputAccessoryView = toolbar
        genderTextField.inputView = gender
    }
    
    func setPreviousActivity() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressed))
        toolbar.setItems([doneButton], animated: true)
        previousActivity.delegate = self
        previousActivityTextField.inputAccessoryView = toolbar
        previousActivityTextField.inputView = previousActivity
    }
    
    func setPhysicalCondition() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressed))
        toolbar.setItems([doneButton], animated: true)
        physicalCondition.delegate = self
        physicalConditionTextField.inputAccessoryView = toolbar
        physicalConditionTextField.inputView = physicalCondition
    }
    
    @objc func doneButtonPressed() {
        self.view.endEditing(true)
    }
    
    func setInjuries() {
        injuriesTextField.delegate = self
    }
    
    func setChronicDiseases() {
        chronicDiseasesTextField.delegate = self
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let gender = genderTextField.text
        let injuries = injuriesTextField.text
        let chronicDiseases = chronicDiseasesTextField.text
        let physicalCondition = physicalConditionTextField.text
        let previousActivity = previousActivityTextField.text
        firbaseService.setDataToUserInfoAdditional(physicalCondition: physicalCondition!, chronicDiseases: chronicDiseases!, gender: gender!, injuries: injuries!, previousActivity: previousActivity!, date: datePicker.date)
        performSegue(withIdentifier: Constants.SegueTo.AdditionalInfoToMain, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueTo.AdditionalInfoToMain {
            if let destinationVC = segue.destination as? UserProfileController {
                Firestore.firestore().collection("users").addSnapshotListener { (querySnapshot, error) in
                        if let user = User(snapshot: querySnapshot){
                            self.dbData = user
                        }
                        destinationVC.fullNameLabel?.text = "Hey, \(self.dbData.full_name)"
                }
            }
        }
    }
    
}

extension AdditionalInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == gender {
            return genderList.count
        }
        else if pickerView == previousActivity {
            return previousActivityList.count
        }
        else {
            return physicalConditionList.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == gender {
            return genderList[row]
        }
        else if pickerView == previousActivity {
            return previousActivityList[row]
        }
        else {
            return physicalConditionList[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == gender {
            genderTextField.text = genderList[row]
        }
        else if pickerView == previousActivity {
            previousActivityTextField.text = previousActivityList[row]
        }
        else {
            physicalConditionTextField.text = physicalConditionList[row]
        }
    }
}

extension AdditionalInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.view.reloadInputViews()
        return true
    }
}
