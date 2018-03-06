//
//  Locations.swift
//  NoticeMe
//
//  Created by 管 皓 on 2018/2/20.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift

class CustomLocation: Object {
    
    @objc dynamic var locationName = ""
    @objc dynamic var modifiedTime = ""
    @objc dynamic var notified = false
    @objc dynamic var isDisplaying = false
    @objc dynamic var zoom: Float = 14.5

    let locationData = List<Double>()
    var timer: Timer?
    var parentNotice = LinkingObjects(fromType: Notice.self, property: "locations")
    
    func setTime(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
        self.modifiedTime = formatter.string(from: date)
    }

}
