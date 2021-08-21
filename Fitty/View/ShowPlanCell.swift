//
//  ShowPlanCell.swift
//  Fitty
//
//  Created by Filip Popovic
//

import UIKit
import youtube_ios_player_helper
import Firebase

protocol CheckButtonSelectionDelegate: AnyObject {
    func didSelect(_ checkButton: UIButton, on cell: ShowPlanCell)
}

class ShowPlanCell: UITableViewCell, YTPlayerViewDelegate {
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var exerciseStack: UIStackView!
    @IBOutlet weak var roundStack: UIStackView!
    @IBOutlet weak var weekStack: UIStackView!
    @IBOutlet weak var exerciseTextField: UITextField!
    @IBOutlet weak var roundsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var loadTextField: UITextField!
    @IBOutlet weak var loadTypeTextField: UITextField!
    @IBOutlet weak var youtubeVideo: YTPlayerView!
    var check = false
    weak var delegate: CheckButtonSelectionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        youtubeVideo.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
    }
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return UIColor.systemGray
    }
    
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        delegate?.didSelect(sender, on: self)
        self.check.toggle()
    }    
}
