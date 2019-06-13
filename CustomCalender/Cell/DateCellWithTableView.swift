//
//  DateCellWithTableView.swift
//  CustomCalender
//
//  Created by SC on 12/06/19.
//  Copyright © 2019 Softices. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCellWithTableView: JTAppleCell {
    @IBOutlet var lblDate: UILabel!
    @IBOutlet weak var viewSelected: UIView!
    @IBOutlet weak var viewFront: UIView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var viewToday: UIView!
    @IBOutlet weak var tblEvent: UITableView!
    
    var eventName = [String]()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        tblEvent.dataSource = self
        tblEvent.dataSource = self
        tblEvent.rowHeight = UITableView.automaticDimension
        tblEvent.tableFooterView = UIView()
    }
}

extension DateCellWithTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblEvent.dequeueReusableCell(withIdentifier: "EventTableCell") as! EventTableCell
        cell.lblTitle.text = eventName[indexPath.row]
        return cell
    }
}
