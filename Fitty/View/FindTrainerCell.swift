//
//  FindTrainerCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit

protocol FindTrainerCellDelegate: AnyObject {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindTrainerCell)
}

class FindTrainerCell: UITableViewCell {
    
    weak var delegate: FindTrainerCellDelegate?
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLabel.textColor = .systemOrange
        followButton.layer.borderColor = UIColor.systemOrange.cgColor
        followButton.tintColor = .clear
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = followButton.frame.height / 2
        followButton.clipsToBounds = true
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
        
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        delegate?.didTapFollowButton(sender, on: self)
    }
    
}
