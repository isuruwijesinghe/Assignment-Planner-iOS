//
//  EditAssessmentViewController.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/12/20.
//  Copyright © 2020 Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class EditAssessmentViewController: UIViewController {
    
    @IBOutlet weak var assmntNameTF: UITextField!
    @IBOutlet weak var assmntModuleTF: UITextField!
    @IBOutlet weak var assmntNotesTF: UITextField!
    @IBOutlet weak var levelSegment: UISegmentedControl!
    @IBOutlet weak var valueTF: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    var current_assessment: Assessment?
    var level: Int16 = 3
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var addToCalender: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //set values to fields
        assmntNameTF.text = current_assessment?.name
        assmntModuleTF.text = current_assessment?.module
        assmntNotesTF.text = current_assessment?.notes
        valueTF.text = String(current_assessment?.value ?? 0)
        dueDatePicker.date = current_assessment!.due ?? Date()
        
        //segmented view for edit project
        switch current_assessment?.level {
        case Int16(3)?:
            levelSegment.selectedSegmentIndex = 0
        case Int16(4)?:
            levelSegment.selectedSegmentIndex = 1
        case Int16(5)?:
            levelSegment.selectedSegmentIndex = 2
        case Int16(6)?:
            levelSegment.selectedSegmentIndex = 3
        case Int16(7)?:
            levelSegment.selectedSegmentIndex = 4
            
        default:
            levelSegment.selectedSegmentIndex = 0
        }
        
    }
    
    //  lavel values changed listner
    @IBAction func levelSegmentValueChanged(_ sender: UISegmentedControl) {
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
    
    //add to calander value changed
    @IBAction func isCalanderChanged(_ sender: UISwitch) {
        addToCalender = sender.isOn
    }
    
    //edit button clicked
    @IBAction func editAssessment(_ sender: UIBarButtonItem) {
        if assmntNameTF.text != "" && assmntModuleTF.text != "" && valueTF.text != ""{
            
            let name = assmntNameTF.text
            let due = dueDatePicker.date
            
            current_assessment?.name = name
            current_assessment?.module = assmntModuleTF.text
            current_assessment?.due = due
            let value: Double = Double(valueTF.text!)!
            current_assessment?.value = value
            
            //save to core data
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //add to clander
            if addToCalender{
                let eventStore: EKEventStore = EKEventStore()
                eventStore.requestAccess(to: .event) {(granted, error) in
                    if (granted) && (error == nil) {
                        let event: EKEvent = EKEvent(eventStore: eventStore)
                        event.title = name
                        event.startDate = self.current_assessment?.start
                        event.endDate = due
                        event.calendar = eventStore.defaultCalendarForNewEvents
                        do {
                            try eventStore.save(event, span: .thisEvent)
                        } catch let error as NSError {
                            fatalError("Unresolved error \(error), \(error.userInfo)")
                        }
                    } else {
                        //                        print("error: \(String(describing: error))")
                    }
                }
            }
            
            dismiss(animated: true, completion: nil)
            
        }else{
            //show errors in fields
            let redColour = UIColor.red
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            
            if (assmntNameTF.text == "") {
                assmntNameTF.layer.borderColor = redColour.cgColor
                assmntNameTF.layer.borderWidth = 1.0
                animation.fromValue = NSValue(cgPoint: CGPoint(x: assmntNameTF.center.x - 10, y: assmntNameTF.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: assmntNameTF.center.x + 10, y: assmntNameTF.center.y))
                assmntNameTF.layer.add(animation, forKey: "position")
            }
            if (assmntModuleTF.text == "") {
                assmntModuleTF.layer.borderColor = redColour.cgColor
                assmntModuleTF.layer.borderWidth = 1.0
                animation.fromValue = NSValue(cgPoint: CGPoint(x: assmntModuleTF.center.x - 10, y: assmntModuleTF.center.y))
                animation.toValue = NSValue(cgPoint: CGPoint(x: assmntModuleTF.center.x + 10, y: assmntModuleTF.center.y))
                assmntModuleTF.layer.add(animation, forKey: "position")
            }
        }
        
    }
    
    // cancel butto clicked
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
