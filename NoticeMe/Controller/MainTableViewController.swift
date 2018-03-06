//
//  MainTableViewController.swift
//  NoticeMe
//
//  Created by 管 皓 on 2018/2/17.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift

class MainTableViewController: UITableViewController, SwipeTableViewCellDelegate, UITextFieldDelegate {
    
    var storedNotices: Results<Notice>?
    var nextAdded: UITextField!
    @IBOutlet var noticeTableView: UITableView!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Notices"
        navigationController!.navigationBar.backgroundColor = UIColor.brown
        noticeTableView.backgroundView = UIImageView(image: UIImage(named: "background"))
        noticeTableView.rowHeight = 64.5
        noticeTableView.register(UINib(nibName: "NoticeTableViewCell", bundle: nil), forCellReuseIdentifier: "noticeCell")
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    @IBAction func addNewButtonPressed(_ sender: UIBarButtonItem) {
        
        let currentDate = getCurrentTime(date: Date())
        let alert = UIAlertController(title: "Add New Notice", message: "", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.text = "New Notice on \(currentDate)"
            self.nextAdded = alertTextField
            self.nextAdded.delegate = self
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (alertAction) in
            let newNotice = self.nextAdded.text!
            let notice = Notice()
            notice.noticeName = newNotice
            notice.setTime(date: Date())
            self.save(notice: notice)
            self.noticeTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        textField.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
            self.updateModel(at: indexPath)
        }
        deleteAction.image = UIImage(named: "bin")
        return [deleteAction]
    }
    
    func updateModel(at indexPath: IndexPath) {
        if let delete = storedNotices?[indexPath.section] {
            do {
                try self.realm.write {
                    self.realm.delete(delete)
                    self.noticeTableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func save(notice: Notice) {
        do {
            try realm.write {
                realm.add(notice)
            }
        } catch {
            print(error)
        }
    }
    
    func loadData() {
        let sortProperties = [SortDescriptor(keyPath: "marked", ascending: false), SortDescriptor(keyPath: "modifiedTime", ascending: false)]
        storedNotices = realm.objects(Notice.self).sorted(by: sortProperties)
    }
    
    func getCurrentTime(date: Date) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd' 'HH:mm:ss"
        let currentDate = formatter.string(from: date)
        return currentDate
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return storedNotices!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = noticeTableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! NoticeTableViewCell
        cell.delegate = self
        cell.backgroundColor = UIColor.clear
        cell.noticeName.text = storedNotices?[indexPath.section].noticeName
        cell.updateTimeTextView.text = "Created on \(storedNotices![indexPath.row].modifiedTime)"
        if storedNotices![indexPath.section].marked {
            cell.markButtonOutlet.setImage(UIImage(named: "marked"), for: .normal)
        } else {
            cell.markButtonOutlet.setImage(UIImage(named: "unmarked"), for: .normal)
        }
        cell.markButtonPressedCallback = {
            if let notice = self.storedNotices?[indexPath.section] {
                do {
                    try self.realm.write {
                        notice.marked = !notice.marked
                        self.noticeTableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showNoticeDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! NoticeDetailTableViewController
        if let indexPath = noticeTableView.indexPathForSelectedRow {
            destinationVC.currentNotice = storedNotices?[indexPath.section]
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}





