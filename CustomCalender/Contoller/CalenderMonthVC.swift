//
//  CalenderMonthVC.swift
//  CustomCalender
//
//  Created by SC on 12/06/19.
//  Copyright © 2019 Softices. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalenderMonthVC: UIViewController {
    
    @IBOutlet weak var viewCalender: JTAppleCalendarView!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    
    var numberOfRows = 6
    let dateFormatter = DateFormatter()
    let testCalendar = Calendar(identifier: .gregorian)
    var calendarEvents: [String:[String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        viewCalender.selectDates([Date()])
        viewCalender.scrollToDate(Date(), triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: .none, extraAddedOffset: .zero, completionHandler: nil)
        
        populateDataSource()
    }
    
    //    For calander resizing when orientation of phone changes to landscape from portrait and vice versa
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let visibleDates = viewCalender.visibleDates()
        viewCalender.viewWillTransition(to: .zero, with: coordinator, anchorDate: visibleDates.monthDates.first?.date)
    }
    
    @IBAction func btnActionPrevious(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- HELPER FUNCTIONS

extension CalenderMonthVC {
    func populateDataSource() {
        // update the datrasource
        calendarEvents = [
            "07/06/2019": ["1","2"],
            "15/06/2019": ["One","Two","Three","Four","Five"],
            "17/06/2019": ["A","B","C","D"],
            "21/06/2019": ["onlyData"],
        ]
        viewCalender.reloadData()
    }
}
//MARK: - JTAPPLECALENDER DELEGATE AND DATASOURCE

extension CalenderMonthVC: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2018 01 01")!
        let endDate = formatter.date(from: "2050 12 31")!
        calendar.scrollDirection = .horizontal
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.allowsMultipleSelection = true
        calendar.isRangeSelectionUsed = true

        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       numberOfRows: numberOfRows,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .off,
                                       firstDayOfWeek: DaysOfWeek.sunday,
                                       hasStrictBoundaries: true)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DateCellWithTableView", for: indexPath) as! DateCellWithTableView
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCellWithTableView  else { return }
        cell.lblDate.text = cellState.text
        cell.viewBack.isHidden = true
        cell.viewFront.isHidden = true
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let todayString = dateFormatter.string(from: Date())
        let cellDateString = dateFormatter.string(from: cellState.date)
        if todayString == cellDateString {
            cell.viewToday.layer.cornerRadius = cell.viewToday.frame.height / 2
            cell.viewToday.isHidden = false
        } else {
            cell.viewToday.isHidden = true
        }
        
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellSelected(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
    }
    
    func handleCellTextColor(cell: DateCellWithTableView, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            if cellState.isSelected {
                cell.lblDate.textColor = UIColor.black
            } else {
                cell.lblDate.textColor = UIColor.white
            }
        } else {
            cell.lblDate.textColor = UIColor.lightText
        }
    }
    
    func handleCellSelected(cell: DateCellWithTableView, cellState: CellState) {
        cell.viewSelected.isHidden = !cellState.isSelected
        
        switch cellState.selectedPosition() {
        case .left:
            cell.viewSelected.layer.cornerRadius = cell.viewSelected.frame.height / 2
            cell.viewSelected.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            cell.viewBack.isHidden = false
        case .middle:
            cell.viewSelected.layer.cornerRadius = 0
            cell.viewSelected.layer.maskedCorners = []
            cell.viewFront.isHidden = false
            cell.viewBack.isHidden = false
        case .right:
            cell.viewSelected.layer.cornerRadius = cell.viewSelected.frame.height / 2
            cell.viewSelected.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            cell.viewFront.isHidden = false
        case .full:
            cell.viewSelected.layer.cornerRadius = cell.viewSelected.frame.height / 2
            cell.viewSelected.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            cell.viewBack.isHidden = true
            cell.viewFront.isHidden = true
        default: break
        }
    }
    
    func handleCellEvents(cell: DateCellWithTableView, cellState: CellState) {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: cellState.date)
        if calendarEvents[dateString] == nil {
            cell.tblEvent.isHidden = true
        } else {
            //            cell.viewEvent.layer.cornerRadius = cell.viewEvent.frame.height / 2
            cell.eventName = calendarEvents[dateString]!
            cell.tblEvent.reloadData()
            cell.tblEvent.isHidden = false
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
        dateFormatter.dateFormat = "dd MMM yyyy"
        //        for dateSelected in calendar.selectedDates {
        //            self.calendar(calendar, didDeselectDate: dateSelected, cell: cell, cellState: cellState)
        //        }
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if cellState.dateBelongsTo != .thisMonth {
            return false
        }
        return true // Based on a criteria, return true or false
    }
    
    /// To get name of Month From Date
    ///
    /// - Parameter date: date for which Month name is needed
    fileprivate func nameOfMonthHeader(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        lblYear.text = formatter.string(from: date)
        formatter.dateFormat = "MMMM"
        lblMonth.text = formatter.string(from: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        nameOfMonthHeader(visibleDates.monthDates.first!.date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        nameOfMonthHeader(visibleDates.monthDates.first!.date)
    }
}
