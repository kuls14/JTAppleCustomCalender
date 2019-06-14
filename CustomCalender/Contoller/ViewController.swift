//
//  ViewController.swift
//  CustomCalender
//
//  Created by SC on 11/06/19.
//  Copyright © 2019 Softices. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var viewCalender: JTAppleCalendarView!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var btnToggle: UIButton!
    @IBOutlet weak var constraint: NSLayoutConstraint!
    
    var numberOfRows = 6
    let dateFormatter = DateFormatter()
    let testCalendar = Calendar(identifier: .gregorian)
    var calendarEvents: [String:String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewCalender.selectDates([Date()])
        viewCalender.scrollToDate(Date(), triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: .none, extraAddedOffset: .zero, completionHandler: nil)
        
        //        for Range selection in mulitple selection
        let panGensture = UILongPressGestureRecognizer(target: self, action: #selector(didStartRangeSelecting(gesture:)))
        panGensture.minimumPressDuration = 0.5
        viewCalender.addGestureRecognizer(panGensture)
        
        
        populateDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate =  self
    }
    
    //    For calander resizing when orientation of phone changes to landscape from portrait and vice versa
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let visibleDates = viewCalender.visibleDates()
        viewCalender.viewWillTransition(to: .zero, with: coordinator, anchorDate: visibleDates.monthDates.first?.date)
    }
    
    //    MARK:- BTN AND GESTURE ACTION
    
    @objc func didStartRangeSelecting(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        let rangeSelectedDates = viewCalender.selectedDates
        
        guard let cellState = viewCalender.cellStatus(at: point) else { return }
        
        if !rangeSelectedDates.contains(cellState.date) {
            let dateRange = viewCalender.generateDateRange(from: rangeSelectedDates.first ?? cellState.date, to: cellState.date)
            viewCalender.selectDates(dateRange, keepSelectionIfMultiSelectionAllowed: true)
        } else {
            let followingDay = testCalendar.date(byAdding: .day, value: 1, to: cellState.date)!
            viewCalender.selectDates(from: followingDay, to: rangeSelectedDates.last!, keepSelectionIfMultiSelectionAllowed: false)
        }
    }
    
    @IBAction func btnActionToggle(_ sender: UIButton) {
        if numberOfRows == 6 {
            configureCalenderForWeekFromMonth()
        } else {
            configureCalenderForMonthFromWeek()
        }
    }
    
    @IBAction func btnActionNext(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CalenderMonthVC") as! CalenderMonthVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- HELPER FUNCTIONS

extension ViewController {
    func populateDataSource() {
        // update the datrasource
        calendarEvents = [
            "07/06/2019": "SomeData",
            "15/06/2019": "SomeMoreData",
            "17/06/2019": "MoreData",
            "21/06/2019": "onlyData",
        ]
        viewCalender.reloadData()
    }
    
    fileprivate func anchorDateForWeekToMonthView() -> Date {
        var i = 0
        var monthName = String()
        var scrollToDate = Date()
        for visibledate in viewCalender.visibleDates().monthDates {
            i = i + 1
            dateFormatter.dateFormat = "MM"
            if i == 1 {
                monthName = dateFormatter.string(from: visibledate.date)
            } else {
                if monthName != dateFormatter.string(from: visibledate.date) {
                    break
                }
            }
        }
        if i > 4 {
            scrollToDate = viewCalender.visibleDates().monthDates.first!.date
        } else {
            scrollToDate = viewCalender.visibleDates().monthDates.last!.date
        }
        return scrollToDate
    }
    
    fileprivate func configureCalenderForMonthFromWeek() {
        var dateToScroll = viewCalender.visibleDates().monthDates.first!.date
        var noSelectedDateInWeek = true
        if !viewCalender.selectedDates.isEmpty {
            outter: for dateSelected in viewCalender.selectedDates {
                for dateVisible in viewCalender.visibleDates().monthDates {
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let dateSelectedD = dateFormatter.string(from: dateSelected)
                    let dateVisibleD = dateFormatter.string(from: dateVisible.date)
                    if dateVisibleD == dateSelectedD {
                        dateToScroll = dateVisible.date
                        noSelectedDateInWeek = false
                        break outter
                    }
                }
            }
            if noSelectedDateInWeek {
                dateToScroll = anchorDateForWeekToMonthView()
            }
        } else {
            dateToScroll = anchorDateForWeekToMonthView()
        }
        self.constraint.constant = 300
        self.numberOfRows = 6
        
        animationForHeightOfCalander(dateToScroll)
    }
    
    fileprivate func animationForHeightOfCalander(_ date: Date) {
        UIView.animate(withDuration: 0.2, animations: {
            self.viewCalender.reloadData(withanchor: date)
            self.viewCalender.scrollToDate(date, triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: .none, extraAddedOffset: .zero, completionHandler: nil)
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func configureCalenderForWeekFromMonth() {
        self.constraint.constant = 60
        self.numberOfRows = 1
        
        var dateS = Date()
        var noSelectedDateInMonth = true
        if !viewCalender.selectedDates.isEmpty {
            outter: for dateSelected in viewCalender.selectedDates {
                for dateVisible in viewCalender.visibleDates().monthDates {
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let dateSelectedD = dateFormatter.string(from: dateSelected)
                    let dateVisibleD = dateFormatter.string(from: dateVisible.date)
                    if dateVisibleD == dateSelectedD {
                        dateS = dateSelected
                        noSelectedDateInMonth = false
                        break outter
                    }
                }
            }
            if noSelectedDateInMonth {
                dateS = viewCalender.visibleDates().monthDates.first!.date
            }
        } else {
            dateS = viewCalender.visibleDates().monthDates.first!.date
        }
        animationForHeightOfCalander(dateS)
    }
}

//MARK: - JTAPPLECALENDER DELEGATE AND DATASOURCE

extension ViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2018 01 01")!
        let endDate = formatter.date(from: "2050 12 31")!
        calendar.scrollDirection = .horizontal
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.allowsMultipleSelection = true
        calendar.isRangeSelectionUsed = true
        
        if numberOfRows == 6 {
            return ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: numberOfRows, firstDayOfWeek: DaysOfWeek.sunday)
        } else {
            return ConfigurationParameters(startDate: startDate,
                                           endDate: endDate,
                                           numberOfRows: numberOfRows,
                                           generateInDates: .forFirstMonthOnly,
                                           generateOutDates: .off,
                                           firstDayOfWeek: DaysOfWeek.sunday,
                                           hasStrictBoundaries: false)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
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
    
    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            if cellState.isSelected {
                cell.lblDate.textColor = UIColor.brown
            } else {
                cell.lblDate.textColor = UIColor.black
            }
        } else {
            cell.lblDate.textColor = UIColor.lightText
        }
    }
    
    func handleCellSelected(cell: DateCell, cellState: CellState) {
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
    
    func handleCellEvents(cell: DateCell, cellState: CellState) {
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: cellState.date)
        if calendarEvents[dateString] == nil {
            cell.viewEvent.isHidden = true
        } else {
//            cell.viewEvent.layer.cornerRadius = cell.viewEvent.frame.height / 2
            cell.viewEvent.isHidden = false
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
    
    /// To change Month Name in Header View when calender page is changed
    /// Here we don't need to calculate date for Month View as it already gives first day of month so we can take that date, but for week view we will calculate if we need to show name of previous month or next month from "anchorDateForWeekToMonthView"
    /// - Parameter visibleDates: Visible date for Month view
    fileprivate func setMonthHeaderForMonthAndWeekView(_ visibleDates: DateSegmentInfo) {
        if numberOfRows == 6 {
            nameOfMonthHeader(visibleDates.monthDates.first!.date)
        } else {
            let dateForMonth = anchorDateForWeekToMonthView()
            nameOfMonthHeader(dateForMonth)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setMonthHeaderForMonthAndWeekView(visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setMonthHeaderForMonthAndWeekView(visibleDates)
    }
    
}
