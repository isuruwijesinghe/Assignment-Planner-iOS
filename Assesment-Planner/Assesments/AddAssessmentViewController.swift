//
//  AddAssessmentViewController.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/11/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class AddAssessmentViewController: UIViewController {
    @IBOutlet weak var assmntName: UITextField!
    @IBOutlet weak var assmntModule: UITextField!
    @IBOutlet weak var assmntNotes: UITextField!
    @IBOutlet weak var levelSegmented: UISegmentedControl!
    @IBOutlet weak var assmntValue: UITextField!
    @IBOutlet weak var assmntMarkTF: UITextField!
    @IBOutlet weak var assmntDueDate: UIDatePicker!
    @IBOutlet weak var calenderSwitch: UISwitch!
    
    var level: Int16 = 3
    var addToCalender: Bool = false
    let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let currentDate = NSDate()
        assmntDueDate.minimumDate = currentDate as Date
    }
    
    // select level segmented control
    @IBAction func levelSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            level = 3
        case 1:
            level = 4
        case 2:
            level = 5
        case 3:
            level = 6
        case 4:
            level = 7
        default:
            level = 3
        }
    }
    
    //add to calander switch listner
    @IBAction func calanderValueChanged(_ sender: UISwitch) {
        addToCalender = sender.isOn
        
    }
    
    //add assignment button lick
    @IBAction func addNewAssessment(_ sender: UIBarButtonItem) {
        
        if assmntName.text != "" && assmntModule.text != "" && assmntValue.text != ""{
            
            //save values to core data
            let new_Assesment = Assessment(context: contex)
            
            let name = assmntName.text
            let module = assmntModule.text
            let dueDate = assmntDueDate.date
            let value = Double(assmntValue.text!)
            let mark = Double(assmntMarkTF.text!)
            
            let notes = assmntNotes.text
            
            new_Assesment.name = name
            new_Assesment.module = module
            new_Assesment.notes = notes ?? ""
            new_Assesment.level = level
            new_Assesment.value = value ?? 0
            new_Assesment.mark = mark ?? 0
            
            new_Assesment.due = dueDate
            new_Assesment.start = Date()
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //add to calander
            if addToCalender{
                let eventStore: EKEventStore = EKEventStore()
                eventStore.requestAccess(to: .event) {(granted, error) in
                    if (granted) && (error == nil) {
                        let event: EKEvent = EKEvent(eventStore: eventStore)
                        event.title = name
                        event.startDate = Date()
                        event.endDate = dueDate
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        do {
                            try eventStore.save(event, span: .thisEvent)
                        } catch let error as NSError {
                            fatalError("Unresolved error \(error), \(error.userInfo)")
                        }
                        
                        //add to reminder
                        eventStore.requestAccess(to: EKEntityType.reminder, completion: {
                            (granted, error) in
                            if (granted) && (error == nil) {
                                
                                let reminder:EKReminder = EKReminder(eventStore: eventStore)
                                reminder.title = "\(name ?? "Assessment")"
                                reminder.priority = 2
                                reminder.completionDate = dueDate
                                reminder.notes = notes
                                
                                let alarmTime = dueDate
                                let alarm = EKAlarm(absoluteDate: alarmTime)
                                reminder.addAlarm(alarm)
                                
                                reminder.calendar = eventStore.defaultCalendarForNewReminders()
                                
                                do {
                                    try eventStore.save(reminder, commit: true)
                                } catch {
                                    fatalError("Unresolved error \(error), \(error)")
                                }
                                print("Reminder saved")
                            }
                        })
                        
                    } else {
                        print("error: \(String(describing: error))")
                    }
                }
            }
            dismiss(animated: true, completion: nil)
            
        }else{
            //alert to fill the fields
            let redColour = UIColor.red
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            
            if assmntName.text == ""{
                assmntName.layer.borderColor = redColour.cgColor
                assmntName.layer.borderWidth = 1.0
                animation.fromValue = NSValue(cgPoint: CGPoint(x: assmntName.center.x - 10, y: assmntName.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: assmntName.center.x + 10, y: assmntName.center.y))
                assmntName.layer.add(animation, forKey: "position")
            }
            
            if assmntModule.text == ""{
                assmntModule.layer.borderColor = redColour.cgColor
                assmntModule.layer.borderWidth = 1.0
                animation.fromValue = NSValue(cgPoint: CGPoint(x: assmntModule.center.x - 10, y: assmntModule.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: assmntModule.center.x + 10, y: assmntModule.center.y))
                assmntModule.layer.add(animation, forKey: "position")
            }
            
            if assmntValue.text == ""{
                assmntValue.layer.borderColor = redColour.cgColor
                assmntValue.layer.borderWidth = 1.0
                animation.fromValue = NSValue(cgPoint: CGPoint(x: assmntValue.center.x - 10, y: assmntValue.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: assmntValue.center.x + 10, y: assmntValue.center.y))
                assmntValue.layer.add(animation, forKey: "position")
            }
            
            
        }
        
        
    }
    
    // cancel button click
    @IBAction func cancelBtnClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
