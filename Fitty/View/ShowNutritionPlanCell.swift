//
//  ShowNutritionPlanCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit

class ShowNutritionPlanCell: UITableViewCell {
    
    @IBOutlet weak var mealNameLabel: UITextField!
    @IBOutlet weak var nutritionPlanTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setTextView()
    }
    
    func setTextView() {
        nutritionPlanTextView.selectedTextRange = nutritionPlanTextView.textRange(from: nutritionPlanTextView.beginningOfDocument, to: nutritionPlanTextView.beginningOfDocument)
        nutritionPlanTextView.layer.borderWidth = 0.3
        nutritionPlanTextView.layer.borderColor = UIColor.lightGray.cgColor
        nutritionPlanTextView.layer.cornerRadius = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
