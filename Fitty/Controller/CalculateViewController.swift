//
//  CalculateViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import Firebase

class CalculateViewController: UIViewController {
    
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var weightSlider: UISlider!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!
    
    var bmiCalculator = BMICalculator()
    let firbaseService = FirebaseService()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateButton.layer.cornerRadius = 20
        heightSlider.value = 1.5
        weightSlider.value = 75
    }
    
    @IBAction func heightSliderChanged(_ sender: UISlider) {
        heightLabel.text = String(format: "%.2f", sender.value) + "m"
    }
    
    @IBAction func weightSliderChanged(_ sender: UISlider) {
        weightLabel.text = String(format: "%.0f", sender.value) + "kg"
    }
    
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        let height = heightSlider.value
        let weight = weightSlider.value
        bmiCalculator.calculateBMI(height: height, weight: weight)
        firbaseService.setDataToUserInfo(uidString: Auth.auth().currentUser!.uid, height: String(format: "%.2f", height), weight: String(format: "%.0f", weight), bmiValue: bmiCalculator.getBMI()["bmiValue"]!, bmiAdvice: bmiCalculator.getBMI()["bmiAdvice"]!, physicalCondition: "", chronicDiseases: "", gender: "", injuries: "", previousActivity: "", date: Date.init())
        self.performSegue(withIdentifier: Constants.SegueTo.BMIToBMIResults, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueTo.BMIToBMIResults {
            let destinationVC = segue.destination as! ResultsViewController
            destinationVC.bmiValue = Float(bmiCalculator.getBMI()["bmiValue"] ?? "")
            destinationVC.adviceValue = bmiCalculator.getBMI()["bmiAdvice"] ?? ""
            destinationVC.view.backgroundColor = bmiCalculator.getBMIColor()
        }
    }
}
