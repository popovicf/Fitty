//
//  TrainingPlanListCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import LetterAvatarKit
import Firebase

class WeekCell: UICollectionViewCell {

    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var trainerNameLabel: UILabel!
    @IBOutlet weak var weeksLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var checkButtonLabel: UIButton!
    let user = User()
    let avatarImage = LetterAvatarMaker()
    let service = FirebaseService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateCell()
    }
    
    func updateCell() {
        checkButtonLabel.isHidden = true
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        if self.user.profile_picture != "" {
            self.profileImage.sd_setImage(with: URL(string: self.user.profile_picture), completed: nil)
        } else {
            self.profileImage.image = self.avatarImage.setUsername(self.user.full_name).build()?.roundedImage
        }
        let layer = CAGradientLayer()
        layer.frame = cellView.bounds
        layer.colors = [UIColor(red: 255/255, green: 194/255, blue: 0/255, alpha: 1).cgColor, UIColor(red: 255/255, green: 190/255, blue: 0/255, alpha: 1).cgColor, UIColor(red: 255/255, green: 166/255, blue: 0/255, alpha: 1).cgColor]
        layer.locations = [0.0, 0.4, 1]
        layer.shouldRasterize = true
        layer.startPoint = CGPoint(x: 1, y: 1)
        layer.endPoint = CGPoint(x: 0, y: 0)
        layer.cornerRadius = 30
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.9
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        cellView.layer.addSublayer(layer)
        cellView.addSubview(trainerNameLabel)
        cellView.addSubview(weeksLabel)
        cellView.addSubview(profileImage)
        cellView.addSubview(weekDayLabel)
        cellView.addSubview(checkButtonLabel)
        cellView.alpha = 1
        cellView.layer.cornerRadius = 30
    }
}
