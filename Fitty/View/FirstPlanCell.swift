//
//  FirstPlanCell.swift
//  Fitty
//
//  Created by Filip Popovic
//
import UIKit

class FirstPlanCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var labelImageView: UIImageView!
    
    let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 30
        cellView.alpha = 1
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: self.layer)
        gradientLayer.frame = cellView.bounds
        
        let colorSet = [UIColor(red: 255/255, green: 194/255, blue: 0/255, alpha: 1), UIColor(red: 255/255, green: 190/255, blue: 0/255, alpha: 1), UIColor(red: 255/255, green: 166/255, blue: 0/255, alpha: 1)]
        let location = [0.0, 0.4, 1]
        
        cellView.addGradient(with: gradientLayer, colorSet: colorSet, locations: location)
        cellView.addSubview(planNameLabel)
        cellView.addSubview(labelImageView)
        
        gradientLayer.cornerRadius = 30
        gradientLayer.shadowRadius = 5
        gradientLayer.shadowOpacity = 0.9
        gradientLayer.shadowColor = UIColor.darkGray.cgColor
        gradientLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
    
    func setLabelIcons(_ label: String) {
        switch label {
        case "training":
            labelImageView.image = UIImage.gifImageWithName("output-onlinegiftools-8")!
        case "nutrition":
            labelImageView.image = UIImage.gifImageWithName("output-onlinegiftools-14")!
        case "report":
            labelImageView.image = UIImage.gifImageWithName("output-onlinegiftools-16")!
        default:
            return
        }
    }
}
