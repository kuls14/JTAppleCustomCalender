//
//  DateCell.swift
//  CustomCalender
//
//  Created by SC on 11/06/19.
//  Copyright © 2019 Softices. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTAppleCell {
    @IBOutlet var lblDate: UILabel!
    @IBOutlet weak var viewSelected: UIView!
    @IBOutlet weak var viewFront: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var viewToday: UIView!
    @IBOutlet weak var viewEvent: UIView!
    
}
