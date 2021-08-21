//
//  NewChatUserCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit

class NewChatUserCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
