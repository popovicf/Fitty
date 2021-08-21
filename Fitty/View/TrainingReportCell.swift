//
//  TrainingReportCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit

class TrainingReportCell: UITableViewCell {

    @IBOutlet weak var weekDayLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    var check = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
