//
//  TaskTableViewController.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/12/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tasksTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    var current_assessment: Assessment?
    let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var objectEdit: Task?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tasksTableView.delegate = self
        self.tasksTableView.dataSource = self
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tasksTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask"{
            let controller = segue.destination as? EditTaskViewController
            controller!.task = objectEdit
            controller?.instanceOFTaskTableClass = self
        }else if segue.identifier == "addTask" {
            if let addTaskViewController = segue.destination as? AddTaskViewController {
                addTaskViewController.current_assessment = current_assessment
            }
        }
    }
    
    //edit button click on task tool bar
    @IBAction func editBtnClicked(_ sender: UIBarButtonItem) {
        if editButton.title == "Edit"{
            tasksTableView.setEditing(true, animated: true)
            editButton.title = "Done"
        }else{
            tasksTableView.setEditing(false, animated: true)
            editButton.title = "Edit"
        }
    }
    
    // MARK: - tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        setCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (rowAction, view , handler)  in
            //TODO: edit the row at indexPath here
            self.objectEdit = self.fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "editTask", sender: self)
        }
        editAction.backgroundColor = UIColor.init(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
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
    
    //set cell task values
    func setCell(_ cell: TaskTableViewCell, indexPath: IndexPath){
        if([fetchedResultsController.fetchedObjects!.count] > [0] && [fetchedResultsController.fetchedObjects!.count] > [indexPath.row]){
            let task = self.fetchedResultsController.fetchedObjects?[indexPath.row]
            cell.task = task
        }else{
            //            print("nil objects")
        }
        
    }
    
    
    // MARK: - Fetched results controller
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Task> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let current_assessment = self.current_assessment
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if current_assessment != nil {
            let predicate = NSPredicate(format: "taskAssessment == %@", current_assessment!)
            fetchRequest.predicate = predicate
        }else{
            //TODO: Handle display when a assessment is not selected
        }
        
        let aFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: contex,
            sectionNameKeyPath: #keyPath(Task.assessment),
            cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            if current_assessment != nil {
            try _fetchedResultsController!.performFetch()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return aFetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult> as! NSFetchedResultsController<Task>
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tasksTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tasksTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tasksTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tasksTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tasksTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if (self.tasksTableView.cellForRow(at: indexPath!) != nil) {
                setCell(self.tasksTableView.cellForRow(at: indexPath!)! as! TaskTableViewCell, indexPath: newIndexPath!)
            }
        case .move:
            self.tasksTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //        tasksTableView.reloadData()
        self.tasksTableView.endUpdates()
    }
    
}

