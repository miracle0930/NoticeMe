//
//  Notice.swift
//  NoticeMe
//
//  Created by 管 皓 on 2018/2/17.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import Foundation
import RealmSwift

class Notice: Object {
    
    @objc dynamic var noticeName = ""
    @objc dynamic var modifiedTime = ""
    @objc dynamic var content = ""
    @objc dynamic var timeAlert = "No Time Alert Enabled on This Notice."

    @objc dynamic var marked = false
    @objc dynamic var enableMap = false
    @objc dynamic var enableClock = false
    @objc dynamic var finished = false
    
    let locations = List<CustomLocation>()

    
    func setTime(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
        self.modifiedTime = formatter.string(from: date)
    }
    
}
    
    
//    init(name: String) {
//        self.noticeName = name
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
//        self.time = formatter.string(from: date)
//    }
//
//    func getName() -> String {
//        return self.noticeName
//    }
//
//    func setName(name: String) {
//        self.noticeName = name
//    }
//
//    func getItems() -> [String] {
//        return self.items
//    }
//
//    func setItems(items: [String]) {
//        self.items = items
//    }
//
//    func getTime() -> String {
//        return self.time
//    }
//
//    func setTime(date: Date) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
//        self.time = formatter.string(from: date)
//    }
    

