//
//  AddTaskViewController.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/12/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import EventKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var notesTF: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var isCalanderSwitch: UISwitch!
    
    var current_assessment: Assessment?
    var addToCalender: Bool = false
    let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let currentDate = NSDate()
        startDatePicker.minimumDate = currentDate as Date
        dueDatePicker.minimumDate = currentDate as Date
    }
    
    //add to calander switch
    @IBAction func calanderValueChanged(_ sender: UISwitch) {
        addToCalender = sender.isOn
    }
    
    // add button click set the values core data and show errors
    @IBAction func addNewTask(_ sender: UIBarButtonItem) {
        
        let redColour = UIColor.red
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        
        if taskNameTF.text != ""{
            let taskName = taskNameTF.text
            let taskNote = notesTF.text
            let startDate = startDatePicker.date
            let dueDate = dueDatePicker.date
            
            if (startDate >= dueDate){
                dueDatePicker.layer.borderColor = redColour.cgColor
                dueDatePicker.layer.borderWidth = 1.0
                animation.fromValue = NSValue(cgPoint: CGPoint(x: dueDatePicker.center.x - 10, y: dueDatePicker.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: dueDatePicker.center.x + 10, y: dueDatePicker.center.y))
                dueDatePicker.layer.add(animation, forKey: "position")
            }else{
                
                let new_task = Task(context: contex)
                new_task.assessment = current_assessment?.name
                new_task.name = taskName
                new_task.notes = taskNote
                new_task.start = startDate
                new_task.due = dueDate
                
                //save to core data
                current_assessment?.addToTasks(new_task)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                //Add notification function if date is due
                if addToCalender {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
                    
                    let content = UNMutableNotificationContent()
                    content.title = taskName!
                    content.subtitle = "Assessment Task Overdue"
                    content.body = taskNote!
                    content.categoryIdentifier = "alarm"
                    content.badge = 1
                    
                    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dueDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                    let request = UNNotificationRequest(identifier: "taskDue", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                    //add to reminder
                    let eventStore: EKEventStore = EKEventStore()
                    eventStore.requestAccess(to: EKEntityType.reminder, completion: {
                        granted, error in
                        if (granted) && (error == nil) {

                            let reminder:EKReminder = EKReminder(eventStore: eventStore)
                            reminder.title = "\(taskName ?? "Task")"
                            reminder.priority = 2
                            reminder.completionDate = dueDate
                            reminder.notes = taskNote


                            let alarmTime = dueDate
                            let alarm = EKAlarm(absoluteDate: alarmTime)
                            reminder.addAlarm(alarm)

                            reminder.calendar = eventStore.defaultCalendarForNewReminders()


                            do {
                                try eventStore.save(reminder, commit: true)
                            } catch {
                                print("Cannot save")
                                return
                            }
                            print("Reminder saved")
                        }
                    })

                }
                dismiss(animated: true, completion: nil)
            }
        }else{
            //show and error if empty
            taskNameTF.layer.borderColor = redColour.cgColor
            taskNameTF.layer.borderWidth = 1.0
            animation.fromValue = NSValue(cgPoint: CGPoint(x: taskNameTF.center.x - 10, y: taskNameTF.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: taskNameTF.center.x + 10, y: taskNameTF.center.y))
            taskNameTF.layer.add(animation, forKey: "position")
            
        }
    }
    
    //cancel button click
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}
