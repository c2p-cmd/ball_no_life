//
//  Extensions.swift
//  BallNoLie
//
//  Created by Sharan Thakur on 27/01/24.
//

import Foundation

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}


extension Date {
    var myFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        return formatter.string(from: self)
    }
}
