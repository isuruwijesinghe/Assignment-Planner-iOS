//
//  MainTableViewController.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/11/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var buttonEdit: UIBarButtonItem!
    var detailViewController: AssessmentDetailViewController? = nil
    var objectEdit: Assessment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = controllers[controllers.count-1] as? AssessmentDetailViewController
        }
        
    }
    
    //edit button click function - on Toolbar
    @IBAction func editBtnClick(_ sender: UIBarButtonItem) {
        if buttonEdit.title == "Edit"{
            tableView.setEditing(true, animated: true)
            buttonEdit.title = "Done"
        }else{
            tableView.setEditing(false, animated: true)
            buttonEdit.title = "Edit"
        }
        
        
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as? AssessmentDetailViewController
                controller!.assessment = object
            }
        }else if segue.identifier == "editAssessment"{
            let controller = segue.destination as? EditAssessmentViewController
            controller!.current_assessment = objectEdit
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "assessmentCell", for: indexPath) as! AssessmentListTableViewCell
        let assessment = fetchedResultsController.object(at: indexPath)
        setCell(cell, withAssessment: assessment)
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
        self.performSegue(withIdentifier: "showDetails", sender: self)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.objectEdit = self.fetchedResultsController.object(at: indexPath)
        self.performSegue(withIdentifier: "showDetails", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    //cell slide controle fucntion delete and edit
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (rowAction, view , handler)  in
            //TODO: edit the row at indexPath here
            self.objectEdit = self.fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "editAssessment", sender: self)
            
        }
        editAction.backgroundColor = .purple
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (rowAction, view, handler) in
            //TODO: Delete the row at indexPath here
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //                let nserror = error as NSError
                //                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
        }
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [editAction,deleteAction])
        return configuration
    }
    
    
    // set values of labels in the cell
    func setCell(_ cell: AssessmentListTableViewCell, withAssessment assessment: Assessment){
        
        cell.assmntNameLabel.text = assessment.name
        cell.assmntModuleLabel.text = assessment.module
        
        cell.assmntValueLabel.text = "Value: \(Int(assessment.value))%"
        cell.assmntMarkLabel.text = "Mark: \(Int(assessment.mark))%"
        
        let dueDate = assessment.due
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: dueDate!)
        let yourDate = formatter.date(from: myString)
        formatter.dateFormat = "dd/MMM/yyyy"
        let myStringafd = formatter.string(from: yourDate!)
        cell.assmntDueDateLabel.text = myStringafd
        
        let currentDate = Date()
        let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: currentDate, to: dueDate!)
        cell.assmntDueTimeLabel.text = "\(diff.day!)d \(diff.hour!)h \(diff.minute!)m";
        
        //if the due date passed it shows in red color
        if (currentDate > dueDate!) {
            cell.assmntDueTimeLabel.textColor = UIColor.red
        }
        
    }
    
    
    // MARK: - Fetch CoreData results
    
    var fetchedResultsController: NSFetchedResultsController<Assessment> {
        if _fetchedResultsController != nil{
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Assessment> = Assessment.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let sort = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contex, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Assessment>? = nil
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            setCell(tableView.cellForRow(at: indexPath!)! as! AssessmentListTableViewCell, withAssessment: anObject as! Assessment)
        case .move:
            setCell(tableView.cellForRow(at: indexPath!)! as! AssessmentListTableViewCell, withAssessment: anObject as! Assessment)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
