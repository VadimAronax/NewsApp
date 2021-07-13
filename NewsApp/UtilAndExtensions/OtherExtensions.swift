//
//  OtherExtensions.swift
//  NewsApp
//
//  Created by Admin on 7.07.21.
//

import Foundation
import UIKit

extension Date {
    func timeAgoSinceDate() -> String {
        // From Time
        let fromDate = self
    
        // To Time
        let toDate = Date()
       // print(fromDate)
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
    
    func getDayBefore(from: Date) -> Date {
        let daybefore = Calendar.current.date(byAdding: .day, value: -1, to: from)!
        return daybefore
    }
}

extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

extension UILabel{
    
    var isTruncated: Bool {
           layoutIfNeeded()

           let rectBounds = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
           var fullTextHeight: CGFloat?

           if attributedText != nil {
               fullTextHeight = attributedText?.boundingRect(with: rectBounds, options: .usesLineFragmentOrigin, context: nil).size.height
           } else {
            fullTextHeight = text?.boundingRect(with: rectBounds, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil).size.height
           }
           return (fullTextHeight ?? 0) > bounds.size.height
       }
}
