//
//  NutritionWeekCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import LetterAvatarKit
import Firebase

class NutritionWeekCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var weeksPlanLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    let user = User()
    let avatarImage = LetterAvatarMaker()
    let service = FirebaseService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateCell()
    }
    
    func updateCell() {
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.contentMode = .scaleAspectFill
        if self.user.profile_picture != "" {
            self.profilePicture.sd_setImage(with: URL(string: self.user.profile_picture), completed: nil)
        } else {
            self.profilePicture.image = self.avatarImage.setUsername(self.user.full_name).build()?.roundedImage
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
        cellView.addSubview(fullNameLabel)
        cellView.addSubview(weeksPlanLabel)
        cellView.addSubview(profilePicture)
        cellView.addSubview(weekDayLabel)
        cellView.alpha = 1
        cellView.layer.cornerRadius = 30
    }
}
