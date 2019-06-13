//
//  EventTableCell.swift
//  CustomCalender
//
//  Created by SC on 12/06/19.
//  Copyright © 2019 Softices. All rights reserved.
//

import UIKit

class EventTableCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
