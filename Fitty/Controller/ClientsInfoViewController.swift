//
//  ClientsInfoViewController.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import LetterAvatarKit

class ClientsInfoViewController: UIViewController {
    
    @IBOutlet weak var physicalConditionStack: UIStackView!
    @IBOutlet weak var designView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var stackPicView: UIStackView!
    @IBOutlet weak var viewScrollView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var createNutritionButton: UIButton!
    @IBOutlet weak var createTreningButton: UIButton!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var bioStackView: UIStackView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bmiValue: UILabel!
    @IBOutlet weak var bmiValueLabel: UILabel!
    @IBOutlet weak var bmiAdvice: UILabel!
    @IBOutlet weak var bmiAdviceLabel: UILabel!
    @IBOutlet weak var physicalConditionLabel: UILabel!
    @IBOutlet weak var physicalCondition: UILabel!
    @IBOutlet weak var previousActivityLabel: UILabel!
    @IBOutlet weak var chronicDiseasesLabel: UILabel!
    @IBOutlet weak var chronicDiseases: UILabel!
    @IBOutlet weak var injuriesLabel: UILabel!
    @IBOutlet weak var injuries: UILabel!
    var user = User()
    var userInfo = UserInfo()
    let avatarImage = LetterAvatarMaker()
    var isAdmin: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(designView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.addUnderlineForSelectedSegment2()
        changeInterface(segmentedControl.selectedSegmentIndex)
        setClientInfo()
    }
    
    func checkIfAdmin(isAdmin: Bool){
        self.isAdmin = isAdmin
    }
    
    func changeInterface(_ index: Int) {
        switch index {
        case 0:
            scrollView.addSubview(bioStackView)
            stackPicView.isHidden = false
            segmentedControl.isHidden = false
            scrollView.isHidden = false
            bioStackView.isHidden = false
            infoStackView.isHidden = true
            profilePic.isHidden = false
        case 1:
            stackPicView.isHidden = true
            segmentedControl.isHidden = false
            scrollView.isHidden = false
            bioStackView.isHidden = true
            infoStackView.isHidden = false
            profilePic.isHidden = true
        default:
            break
        }
        
        switch isAdmin {
        case false:
            createNutritionButton.isHidden = true
            createTreningButton.isHidden = true
            bmiValue.isHidden = true
            bmiValueLabel.isHidden = true
            bmiAdvice.isHidden = true
            bmiAdviceLabel.isHidden = true
            injuries.isHidden = true
            injuriesLabel.isHidden = true
            chronicDiseasesLabel.isHidden = true
            chronicDiseases.isHidden = true
            
        default:
            createNutritionButton.isHidden = false
            createTreningButton.isHidden = false
            bmiValue.isHidden = false
            bmiValueLabel.isHidden = false
            bmiAdvice.isHidden = false
            bmiAdviceLabel.isHidden = false
            injuries.isHidden = false
            injuriesLabel.isHidden = false
            chronicDiseasesLabel.isHidden = false
            chronicDiseases.isHidden = false
            physicalCondition.isHidden = false
            physicalConditionLabel.isHidden = false
        }
    }
    
    func setClientInfo(){
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        if self.user.profile_picture != "" {
            self.profilePic.sd_setImage(with: URL(string: self.user.profile_picture), completed: nil)
        } else {
            self.profilePic.image = self.avatarImage.setUsername(self.user.full_name).build()?.roundedImage
        }
        fullNameLabel.text = user.full_name
        emailLabel.text = user.email
        birthDateLabel.text = getDate()
        genderLabel.text = userInfo.gender
        heightLabel.text = userInfo.height
        physicalConditionLabel.text = userInfo.physicalCondition
        previousActivityLabel.text = userInfo.previousActivity
        weightLabel.text = userInfo.weight
        chronicDiseasesLabel.text = userInfo.chronicDiseases
        bmiAdvice.text = userInfo.bmiAdvice
        injuriesLabel.text = userInfo.injuries
        bmiValue.text = String(format: "%.1f", (userInfo.bmiValue as NSString).doubleValue)
        createTreningButton.layer.cornerRadius = 20
        createNutritionButton.layer.cornerRadius = 20
        createTreningButton.layer.borderWidth = 1
        createTreningButton.layer.borderColor = UIColor.systemOrange.cgColor
        createTreningButton.setImage(#imageLiteral(resourceName: "trainingPlan"), for: .normal)
        createTreningButton.alignImageRight()
        createTreningButton.tintColor = .systemOrange
        createNutritionButton.setImage(#imageLiteral(resourceName: "nutritionPlan"), for: .normal)
        createNutritionButton.alignImageRigh2()
        createNutritionButton.tintColor = .white
        designView.layer.cornerRadius = 50
        designView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        designView.layer.shadowRadius = 20.0
        designView.layer.shadowOpacity = 0.9
        designView.layer.shadowColor = UIColor.darkGray.cgColor
        designView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        createTreningButton.layer.shadowRadius = 5
        createTreningButton.layer.shadowOpacity = 0.9
        createTreningButton.layer.shadowColor = UIColor.darkGray.cgColor
        createTreningButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        createNutritionButton.layer.shadowRadius = 5
        createNutritionButton.layer.shadowOpacity = 0.9
        createNutritionButton.layer.shadowColor = UIColor.darkGray.cgColor
        createNutritionButton.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        if isAdmin == false {
            self.physicalCondition.removeFromSuperview()
            self.physicalConditionLabel.removeFromSuperview()
            self.physicalConditionStack.removeFromSuperview()
        } 
    }
    
    func getDate() -> String {
        let timestamp = (userInfo.birthDate)?.dateValue()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "MM/dd/YYYY"
        let date = formatter.string(from: timestamp ?? .distantPast)
        return date
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        changeInterface(segmentedControl.selectedSegmentIndex)
        segmentedControl.changeUnderlinePosition()
    }
    @IBAction func createTrainingButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.SegueTo.clientsInfoToTrainingPlan, sender: self)
    }
    @IBAction func createNutritionButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.SegueTo.clientsInfoToNutritionPlan, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.SegueTo.clientsInfoToTrainingPlan {
            let destinationVC = segue.destination as! TrainingPlanViewController
            destinationVC.user = user
        }
        if segue.identifier == Constants.SegueTo.clientsInfoToNutritionPlan {
            let destinationVC = segue.destination as! NutritionPlanViewController
            destinationVC.user = user
        }
    }
}
