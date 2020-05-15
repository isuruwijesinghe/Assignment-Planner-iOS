//
//  AssessmentDetailViewController.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/10/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData

class AssessmentDetailViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //    func configureView() {
    //        // Update the user interface for the detail item.
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        configureView()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "assessmentSummaryView"{
            if let assessmentSummaryViewController = segue.destination as? AssessmentSummaryViewController {
                assessmentSummaryViewController.current_assessment = assessment
            }
        }else if segue.identifier == "addTask" {
            if let addTaskViewController = segue.destination as? AddTaskViewController {
                addTaskViewController.current_assessment = assessment
            }
        }else if segue.identifier == "tasksList" {
            if let tasksViewController = segue.destination as? TaskTableViewController {
                tasksViewController.current_assessment = assessment
            }
        }
    }
    
    var assessment: Assessment?{
        didSet{
            //update the view
            //            configureView()
        }
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
