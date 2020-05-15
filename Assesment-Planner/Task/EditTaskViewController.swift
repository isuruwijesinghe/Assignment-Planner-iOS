//
//  EditTaskViewController.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/12/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class EditTaskViewController: UIViewController {
    
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var taskNoteTF: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var isCalanderSwitch: UISwitch!
    
    var task: Task?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var addToCalender: Bool = false
    
    var instanceOFTaskTableClass: TaskTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if (task != nil) {
            taskNameTF.text = task?.name
            startDatePicker.date = (task?.start)!
            dueDatePicker.date = (task?.due)!
            taskNoteTF.text = task?.notes
        }
    }
    //add to calander switch value
    @IBAction func isCalanderValueChanged(_ sender: UISwitch) {
        addToCalender = sender.isOn
    }
    
    // edit button click save changed date to core data and show errors
    @IBAction func editTask(_ sender: UIBarButtonItem) {
        //set data to core data
        task?.start = startDatePicker.date
        task?.due = dueDatePicker.date
        task?.notes = taskNoteTF.text
        task?.name = taskNameTF.text
        
        if taskNameTF.text != "" {
            //save to core data
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //add to calander
            if addToCalender {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
                //calander details
                let content = UNMutableNotificationContent()
                content.title = taskNameTF.text!
                content.subtitle = "Assessment Task Overdue"
                content.body = taskNoteTF.text!
                content.categoryIdentifier = "alarm"
                content.badge = 1
                
                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dueDatePicker.date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let request = UNNotificationRequest(identifier: "taskDue", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
            //reload table after save
            instanceOFTaskTableClass?.tasksTableView.reloadData()
            dismiss(animated: true, completion: nil)
            
        }else{
            //show and error if empty
            let redColour = UIColor.red
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            
            taskNameTF.layer.borderColor = redColour.cgColor
            taskNameTF.layer.borderWidth = 1.0
            animation.fromValue = NSValue(cgPoint: CGPoint(x: taskNameTF.center.x - 10, y: taskNameTF.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: taskNameTF.center.x + 10, y: taskNameTF.center.y))
            taskNameTF.layer.add(animation, forKey: "position")
        }
        
        
    }
    
    //cancel button click
    @IBAction func cancelBtnClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
