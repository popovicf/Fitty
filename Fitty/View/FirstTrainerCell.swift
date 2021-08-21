//
//  FirstTrainerCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import LetterAvatarKit
import Firebase

class FirstTrainerCell: UICollectionViewCell {
    
    @IBOutlet weak var trainerPic: UIImageView!
    @IBOutlet weak var trainerName: UILabel!
    let avatarImage = LetterAvatarMaker()
    let service = FirebaseService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUI(user: User){
        trainerPic.layer.cornerRadius = trainerPic.frame.size.width / 2
        trainerPic.clipsToBounds = true
        trainerPic.contentMode = .scaleAspectFill
        if user.profile_picture != "" {
            self.trainerPic.sd_setImage(with: URL(string: user.profile_picture), completed: nil)
        } else {
            self.trainerPic.image = self.avatarImage.setUsername(user.full_name).build()?.roundedImage
        }
    }
}
