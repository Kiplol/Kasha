//
//  PlaylistControlsTableViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/22/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import Gestalt
import UIKit

class PlaylistControlsTableViewCell: UITableViewCell, SelfSizing {

    // MARK: - IBOutlets
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var buttonShuffle: UIButton!
    @IBOutlet var buttons: [UIButton]!
    var buttonPlayAction: ((UIButton) -> Void)?
    var buttonShuffleAction: ((UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.buttons.forEach {
                $0.backgroundColor = theme.primaryAccentColor
                let otherColor = theme.primaryAccentColor.isDark ? UIColor.white : UIColor.black
                $0.tintColor = otherColor
                $0.setTitleColor(otherColor, for: .normal)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - User Interaction
    @IBAction func playTapped(_ sender: Any) {
        self.buttonPlayAction?(self.buttonPlay)
    }
    
    @IBAction func shuffleTapped(_ sender: Any) {
        self.buttonShuffleAction?(self.buttonShuffle)
    }
    
    // MARK: - SelfSizing
    static func sizeConstrained(toWidth width: CGFloat, withData: Any?) -> CGSize {
        return CGSize(width: width, height: 70.0)
    }
    
}
