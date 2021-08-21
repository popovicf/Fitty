//
//  BMICalculator.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import UIKit

struct BMICalculator {
    
    var userInfo = UserInfo.userInfoInstance
    var color: UIColor?
    
    mutating func calculateBMI(height: Float, weight: Float) {
        
        let bmiValue = weight/pow(height, 2)
        if bmiValue < 18.5 {
            userInfo.setBMI(bmiValue: String(bmiValue), bmiAdvice: "Underweight")
            color = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        } else if bmiValue <= 24.9 {
            userInfo.setBMI(bmiValue: String(bmiValue), bmiAdvice: "Normal")
            color = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        } else {
            userInfo.setBMI(bmiValue: String(bmiValue), bmiAdvice: "Overweight")
            color = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
    }
    
    func getBMIColor() -> UIColor {
        return color ?? .clear
    }
    
    func getBMI() -> [String:String] {
        return ["bmiValue":userInfo.bmiValue, "bmiAdvice":userInfo.bmiAdvice]
    }
}
