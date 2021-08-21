//
//  MessageCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var leftImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageBubble.layer.cornerRadius = self.messageBubble.frame.height / 5
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
