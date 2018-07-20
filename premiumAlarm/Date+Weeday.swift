//
//  Date+Weeday.swift
//  premiumAlarm
//
//  Created by Ryo Endo on 2018/07/20.
//  Copyright © 2018年 Ryo Endo. All rights reserved.
//

import UIKit

extension Date {
    var weekday: String {
        let calendar = Calendar(identifier: .gregorian)
        let component = calendar.component(.weekday, from: self)
        let weekday = component - 1
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja")
        return formatter.weekdaySymbols[weekday]
    }
}
