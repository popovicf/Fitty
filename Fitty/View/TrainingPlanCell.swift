//
//  TrainingPlanCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit

protocol TrainingPlanCellDelegate: AnyObject {
    func trainingPlanCell(_ trainingPlanCell: TrainingPlanCell, newTrainingButtonPressed training: TrainingPlan)
    func selectedTextField(_ trainingPlanCell: TrainingPlanCell, textField: UITextField)
    func pickerViewDidEndEditing()
}

class TrainingPlanCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var roundStack: UIStackView!
    @IBOutlet weak var exerciseStack: UIStackView!
    @IBOutlet weak var videoStack: UIStackView!
    @IBOutlet weak var weekStack: UIStackView!
    @IBOutlet weak var dayTextLabel: UILabel!
    @IBOutlet weak var exerciseTextField: UITextField!
    @IBOutlet weak var roundsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var loadTextField: UITextField!
    @IBOutlet weak var loadTypeTextField: UITextField!
    @IBOutlet weak var videoTextField: UITextField!
    @IBOutlet weak var newTrainingButton: UIButton!
    
    weak var delegate : TrainingPlanCellDelegate?
    var training : TrainingPlan?
    let loadTypePicker = UIPickerView()
    let loadTypeList = ["kg", "%"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.newTrainingButton.addTarget(self, action: #selector(newTrainingButtonPressed(_:)), for: .touchUpInside)
        setLoadType()
    }
    
    func setLoadType() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        toolbar.setItems([doneButton], animated: true)
        loadTypePicker.delegate = self
        loadTypeTextField.text = "kg"
        loadTypeTextField.inputAccessoryView = toolbar
        loadTypeTextField.inputView = loadTypePicker
    }
    
    @objc func doneButtonPressed() {
        delegate?.pickerViewDidEndEditing()
    }
    
    @IBAction func newTrainingButtonPressed(_ sender: UIButton) {
        if let training = training,
           let _ = delegate {
            self.delegate?.trainingPlanCell(self, newTrainingButtonPressed: training)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func exerciseDidEndEditing(_ sender: UITextField) {
        delegate?.selectedTextField(self, textField: sender)
    }
    @IBAction func roundsDidEndEditing(_ sender: UITextField) {
        delegate?.selectedTextField(self, textField: sender)
    }
    @IBAction func repsDidEndEditing(_ sender: UITextField) {
        delegate?.selectedTextField(self, textField: sender)
    }
    @IBAction func loadDidEndEditing(_ sender: UITextField) {
        delegate?.selectedTextField(self, textField: sender)
    }
    @IBAction func loadTypeDidEndEditing(_ sender: UITextField) {
        delegate?.selectedTextField(self, textField: sender)
    }
    @IBAction func videoDidEndEditing(_ sender: UITextField) {
        delegate?.selectedTextField(self, textField: sender)
    }
}
extension TrainingPlanCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.selectedTextField(self, textField: textField)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.selectedTextField(self, textField: textField)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        self.reloadInputViews()
        return true
    }
}
extension TrainingPlanCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        loadTypeList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        loadTypeList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loadTypeTextField.text = loadTypeList[row]
    }
}

