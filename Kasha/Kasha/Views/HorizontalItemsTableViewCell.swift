//
//  HorizontalItemsTableViewCell.swift
//  Kasha
//
//  Created by Elliott Kipper on 7/8/18.
//  Copyright © 2018 Kip. All rights reserved.
//

import UIKit

class HorizontalItemsTableViewCell: UITableViewCell {
    
    var horizontalItemView: HorizontalItemsView {
        guard let hiv = self.contentView as? HorizontalItemsView else {
            preconditionFailure("HorizontalItemsTableViewCell's contentView was not an instance of HorizontalItemView.")
        }
        return hiv
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
