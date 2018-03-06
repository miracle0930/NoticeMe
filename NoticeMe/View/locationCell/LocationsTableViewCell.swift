//
//  LocationsTableViewCell.swift
//  NoticeMe
//
//  Created by 管 皓 on 2018/2/22.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit

class LocationsTableViewCell: UITableViewCell {

    @IBOutlet var modifiedTimeLabel: UITextView!
    @IBOutlet var nameLabel: UILabel!
    var deletebuttonPresedCallBack: (() throws -> ())?
    var locationAlarmButtonPressedCallBack: (() throws -> ())?
    
    @IBOutlet var alarmButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        do {
            try deletebuttonPresedCallBack?()
        } catch {
            print(error)
        }
    }
    
    @IBAction func alarmButtonPressed(_ sender: UIButton) {
        do {
            try locationAlarmButtonPressedCallBack?()
        } catch {
            print(error)
        }
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
