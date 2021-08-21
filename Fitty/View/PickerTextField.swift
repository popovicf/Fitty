//
//  PickerTextField.swift
//  Fitty
//
//  Created by Filip Popovic
//

import SwiftUI

class PickerTextField: UITextField {

    var data: [String]
    @Binding var selectionIndex: Int?
    var settingsData = SettingsViewModel()
    var row: Int?

    init(data: [String], selectionIndex: Binding<Int?>) {
        self.data = data
        self._selectionIndex = selectionIndex
        super.init(frame: .zero)
        
        self.inputView = pickerView
        self.tintColor = .clear
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
            
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        self.inputAccessoryView = toolBar
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()

    @objc private func donePressed() {
        self.selectionIndex = self.pickerView.selectedRow(inComponent: 0)
        let profile = ProfileView()
        if data == profile.genderList {
            settingsData.updateUserInfo(key: "gender", value: data[row!])
        } else if data == profile.physicalConditionList {
            settingsData.updateUserInfo(key: "physical_condition", value: data[row ?? 0])
        } else {
            settingsData.updateUserInfo(key: "previous_activity", value: data[row!])
        }
        self.endEditing(true)
    }
}

extension PickerTextField: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.data[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectionIndex = row
        self.row = row
    }
}
