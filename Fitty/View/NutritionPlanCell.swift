//
//  NutritionPlanCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit

protocol NutritionPlanCellDelegate: AnyObject {
    func nutritionPlanCell(_ nutritionPlanCell: NutritionPlanCell, newNutritionButtonPressed nutrition: NutritionPlan)
    func selectedTextField(_ nutritionPlanCell: NutritionPlanCell, textField: UITextField)
    func selectedTextView(_ nutritionPlanCell: NutritionPlanCell, textField: UITextView)
}

class NutritionPlanCell: UITableViewCell {

    @IBOutlet weak var mealName: UITextField!
    @IBOutlet weak var mealTextView: UITextView!
    @IBOutlet weak var newMealButton: UIButton!
    
    weak var delegate : NutritionPlanCellDelegate?
    var nutrition : NutritionPlan?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mealTextView.delegate = self
        mealName.delegate = self
        self.newMealButton.addTarget(self, action: #selector(newMealButtonPressed(_:)), for: .touchUpInside)
        setTextView()
    }
    
    func setTextView() {
        mealTextView.selectedTextRange = mealTextView.textRange(from: mealTextView.beginningOfDocument, to: mealTextView.beginningOfDocument)
        mealTextView.layer.borderWidth = 0.3
        mealTextView.layer.borderColor = UIColor.lightGray.cgColor
        mealTextView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func newMealButtonPressed(_ sender: UIButton) {
        if let nutrition = nutrition,
           let _ = delegate {
            self.delegate?.nutritionPlanCell(self, newNutritionButtonPressed: nutrition)
        }
    }
    
    @IBAction func mealNameDidEndEditing(_ sender: UITextField) {
        delegate?.selectedTextField(self, textField: sender)
    }
}
extension NutritionPlanCell: UITextViewDelegate, UITextFieldDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        if updatedText.isEmpty {
            textView.text = "Create daily nutrition plan"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
         else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
        else {
            return true
        }
        return false
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.selectedTextView(self, textField: textView)
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.endEditing(true)
        self.reloadInputViews()
        delegate?.selectedTextView(self, textField: textView)
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.selectedTextView(self, textField: textView)
    }
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
