//
//  EditTaskViewController.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/12/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData

class EditTaskViewController: UIViewController {

    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var taskNoteTF: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var isCalanderSwitch: UISwitch!
    
    var task: Task?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
    
    
    @IBAction func editTask(_ sender: UIBarButtonItem) {
        
        task?.start = startDatePicker.date
        task?.due = dueDatePicker.date
        task?.notes = taskNoteTF.text
        task?.name = taskNameTF.text
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
