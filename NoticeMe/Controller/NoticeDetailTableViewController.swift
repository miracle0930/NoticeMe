//
//  NoticeDetailTableViewController.swift
//  NoticeMe
//
//  Created by 管 皓 on 2018/2/19.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class NoticeDetailTableViewController: UITableViewController {
    
    @IBOutlet var noticeNameTextField: UITextField!
    @IBOutlet var timeSettingCell: UITableViewCell!
    @IBOutlet var noticeContentTextView: ContentTextView!
    @IBOutlet var enableTimeAlertOutlet: UISwitch!
    @IBOutlet var enableLocationAlertOutlet: UISwitch!
    @IBOutlet var alertTimeDetail: UILabel!
    @IBOutlet var notificationTimePicker: UIDatePicker!
    @IBOutlet var locationsCell: UITableViewCell!
    @IBOutlet var contentOuterView: UIView!
    
    let realm = try! Realm()
    var currentNotice: Notice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        navigationItem.title = "Edit Notice"
        noticeNameTextField.delegate = self
        noticeContentTextView.delegate = self
        noticeNameTextField.text = currentNotice!.noticeName
        noticeContentTextView.text = currentNotice!.content
        alertTimeDetail.text = currentNotice!.timeAlert
        enableTimeAlertOutlet.isOn = currentNotice!.enableClock
        enableLocationAlertOutlet.isOn = currentNotice!.enableMap
        timeSettingCell.isHidden = !enableTimeAlertOutlet.isOn
        locationsCell.isHidden = !enableLocationAlertOutlet.isOn
        notificationTimePicker.minimumDate = Date()
        contentOuterView.layer.cornerRadius = 20
        contentOuterView.layer.borderWidth = 2
        contentOuterView.layer.borderColor = UIColor.black.cgColor
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func confirmTimelaertPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            let timeAlert = notificationTimePicker.date
            let currentTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd' 'HH:mm"
            let timeString = formatter.string(from: timeAlert)
            let currentTimeString = formatter.string(from: currentTime)
            if timeString < currentTimeString {
                let alertTitle = "Cannot Set Time Alert on This Time"
                let alertMessage = "Please make sure you chosed a future time"
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                let button = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(button)
                present(alert, animated: true, completion: nil)
                return
            }
            alertTimeDetail.text = "Time Alert Enabled on \(timeString)"
            pushNotificationOnSelectedDate(notificationDate: timeAlert)
        } else {
            alertTimeDetail.text = "No Time Alert Enabled on This Notice"
        }

        do {
            try realm.write {
                currentNotice!.timeAlert = self.alertTimeDetail.text!
            }
        } catch {
            print(error)
        }
    }
    
    func pushNotificationOnSelectedDate(notificationDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "This is A Reminder from NoticeMe"
        content.body = "Have you done your task '\(currentNotice!.noticeName)'?"
        content.sound = UNNotificationSound.default()
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.month, .day, .hour, .minute])
        let components = calendar.dateComponents(unitFlags, from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "timeNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    @IBAction func timeAlertEnablePressed(_ sender: UISwitch) {
        do {
            try realm.write {
                currentNotice!.enableClock = !currentNotice!.enableClock
            }
        } catch {
            print(error)
        }
        timeSettingCell.isHidden = !timeSettingCell.isHidden
        tableView.reloadData()
    }
    
    @IBAction func locationAlertEnablePressed(_ sender: UISwitch) {
        do {
            try realm.write {
                currentNotice!.enableMap = !currentNotice!.enableMap
            }
        } catch {
            print(error)
        }
        locationsCell.isHidden = !locationsCell.isHidden
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 1 {
            performSegue(withIdentifier: "manageLocations", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor.clear
        if indexPath.section == 1 {
            
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! LocationsViewController
        destinationVC.currentNotice = currentNotice
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && (indexPath.row == 3 || indexPath.row == 2) {
            if enableTimeAlertOutlet.isOn {
                if indexPath.row == 3 {
                    return 162
                } else {
                    return 24
                }
            } else {
                return 0
            }
        } else if indexPath.section == 1 {
            return 200
        } else if indexPath.section == 2 && indexPath.row == 1 {
            if enableLocationAlertOutlet.isOn {
                return 44
            } else {
                return 0
            }
        }
        return 44
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        noticeContentTextView.setNeedsDisplay()
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 0
        }
    }
}

extension NoticeDetailTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        noticeNameTextField.selectedTextRange = noticeNameTextField.textRange(from: noticeNameTextField.beginningOfDocument, to: noticeNameTextField.endOfDocument)
        noticeNameTextField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        do {
            try realm.write {
                currentNotice!.noticeName = noticeNameTextField.text!
            }
        } catch {
            print(error)
        }
    }
}

extension NoticeDetailTableViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        do {
            try realm.write {
                currentNotice!.content = noticeContentTextView.text!
            }
        } catch {
            print(error)
        }
    }
}



