//
//  ScrollCalendar.swift
//  SwiftOverload
//
//  Created by Milan de Ruiter on 09-08-17.
//  Copyright © 2017 Milan de Ruiter. All rights reserved.
//

import UIKit

protocol ScrollCalendarDelegate {
    func didSelectDate(date: Date)
}

class ScrollCalendar: UIScrollView {
    
    var calendarDelegate: ScrollCalendarDelegate?
    
    // Setters
    
    var datesBackInTime:Int = 14
    
    // Styling
    
    var calendarCellWidth:CGFloat = 50
    var calendarTopOffset:CGFloat = 20
    var calendarBottomOffset:CGFloat = 20
    
    var calendarBackgroundColor:UIColor = UIColor.customDarkGray
    var calendarSelectedBackgroundColor:UIColor = UIColor.customBlue
    
    var cellSpacing:CGFloat = 10
    
    // Variables
    
    var selectedCell:UIView? = nil
    var dates:[Date] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.isScrollEnabled = true
        
        // Load dates
        self.dates = loadDates().reversed()
        
        // Set content
        self.contentSize = CGSize(
            width: cellSpacing + CGFloat( self.dates.count) * (calendarCellWidth + cellSpacing),
            height: 50
        )
        
        // Set offset
        self.contentOffset = CGPoint(x: self.contentSize.width - frame.size.width, y: 0)
        
        // Setup
        self.setupCalendarView()
        
        calendarDelegate?.didSelectDate(date: Date())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupCalendarView() {
        
        self.backgroundColor = calendarBackgroundColor
        
        for i in 0 ..< dates.count {
            
            let date:Date = dates[i]
            let index:CGFloat = CGFloat(i)
            let totalCellWidth:CGFloat = calendarCellWidth + cellSpacing
            
            let cell:UIView = UIView()
            cell.frame = CGRect(
                x: cellSpacing + index * totalCellWidth,
                y: calendarTopOffset,
                width: calendarCellWidth,
                height: self.frame.size.height - calendarTopOffset - calendarBottomOffset
            )
            
            cell.tag = i
            cell.layer.cornerRadius = 2
            
            // Daylabel: 1
            let dayLabel:UILabel = initDateLabel(for: date)
            cell.addSubview(dayLabel)
            
            // DayName: Monday
            let dayNameLabel:UILabel = initDateNameLabel(for: date)
            cell.addSubview(dayNameLabel)
            
            // MonthName: January
            let monthLabel:UILabel = initMonthNameLabel(for: date)
            cell.addSubview(monthLabel)
            
            // Gesture
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.calendarCellTapped(_:)))
            cell.addGestureRecognizer(tap)
            
            self.addSubview(cell)
        }
    }
    
    private func initDateNameLabel(for date:Date) -> UILabel {
        let name = getDayName(for: date)
        let stringIndex = name.index(name.startIndex, offsetBy: 3)
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 5, width: calendarCellWidth, height: 10))
        label.textAlignment = .center
        label.textColor = .customGray
        label.font = UIFont(name: "HelveticaNeue", size: 10)
        label.text = name.substring(to: stringIndex).uppercased()
        return label
    }
    
    private func initDateLabel(for date:Date) -> UILabel {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: date)
        
        let label:UILabel = UILabel()
        label.frame = CGRect(x: 0, y: 20, width: calendarCellWidth, height: 20)
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue", size: 20)
        label.text = "\(components.day!)"
        return label
    }
    
    private func initMonthNameLabel(for date:Date) -> UILabel {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month], from: date)
        let month = components.month
        let name = DateFormatter().monthSymbols[month! - 1]
        let stringIndex = name.index(name.startIndex, offsetBy: 3)
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 45, width: calendarCellWidth, height: 8))
        label.text = name.substring(to: stringIndex).uppercased()
        label.font = UIFont(name: "HelveticaNeue", size: 8)
        label.textColor = .customGray
        label.textAlignment = .center
        return label
    }
    
    private func getDayName(for date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    @objc func calendarCellTapped(_ cell:UITapGestureRecognizer) {
        let view:UIView = cell.view!
        setSelected(cell: view)
        
        let date:Date = dates[view.tag]
        calendarDelegate?.didSelectDate(date: date)
    }
    
    func setSelected(cell:UIView) {
        selectedCell?.backgroundColor = calendarBackgroundColor
        selectedCell = cell
        cell.backgroundColor = .customBlue
    }
    
    func selectToday() {
        for view in self.subviews {
            if view.tag == datesBackInTime - 1 {
                setSelected(cell: view)
            }
        }
    }
    
    func getSelectedDate() -> Date {
        let tag = selectedCell?.tag
        return dates[tag!]
    }
    
    
    // MARK: Helpers
    
    private func loadDates() -> [Date] {
        let today = Date()
        let secondsInADay:TimeInterval = 60 * 60 * 24
        var dateArray:[Date] = []
        for i in 0 ..< datesBackInTime {
            let date:Date = Date(timeInterval: secondsInADay * TimeInterval(i * -1), since: today)
            dateArray.append(date)
        }
        return dateArray
    }
    
}
