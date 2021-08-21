//
//  ClientsCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import Foundation
import UIKit

class ClientsCell: UITableViewCell {
    
    @IBOutlet weak var clientNameLabel: UILabel!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    override func awakeFromNib() {
        nextLabel.layer.borderColor = UIColor.lightGray.cgColor
    }
}
