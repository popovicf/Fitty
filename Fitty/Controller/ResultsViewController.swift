//
//  ResultsViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var adviceLabel: UILabel!
    @IBOutlet weak var recalculatePressed: UIButton!
    @IBOutlet weak var proceedButton: UIButton!
    
    var bmiValue : Float?
    var adviceValue : String?
    
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
        recalculatePressed.layer.cornerRadius = 20
        proceedButton.layer.cornerRadius = 20
        bmiLabel.text = String(format: "%.1f", bmiValue ?? 0.0)
        adviceLabel.text = adviceValue ?? ""
    }
    
    @IBAction func proceedButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.SegueTo.BMIResultsToAdditionalInfo, sender: self)
    }
    
    @IBAction func recalculatePressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
