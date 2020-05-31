//
//  AssessmentSummaryViewController.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/10/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData

class AssessmentSummaryViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var assessmentNameLabel: UILabel!
    @IBOutlet weak var assessmentModuleLabel: UILabel!
    @IBOutlet weak var assessmentLevelLabel: UILabel!
    @IBOutlet weak var assessmntNotesLabel: UILabel!
    //position of progress bars
    let assmntCompletePosition = CGPoint(x: 132, y: 120)
    let assmntDaysLefttPosition = CGPoint(x: 850, y: 120)
    var shapeCompleteLayer = CAShapeLayer()
    var shapeDaysLeftLayer = CAShapeLayer()
    
    var current_assessment: Assessment?
    let contex = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let percentageLable: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    let completeLable: UILabel = {
        let label = UILabel()
        label.text = "complete"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    let daysCountLable: UILabel = {
        let label = UILabel()
        label.text = "100"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    let daysLeftLable: UILabel = {
        let label = UILabel()
        label.text = "left"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //circle to progress
        setPercentageCircles()
        setDaysLeftCircles()
        
        //set label values
        setValuesToLabels()
    }
    
    //set assessment values to the labels
    func setValuesToLabels(){
        
        assessmentNameLabel.text = current_assessment?.name ?? "No Assessment Available yet!"
        assessmentModuleLabel.text = current_assessment?.module ?? "Please Add an Assessment"
        assessmentLevelLabel.text = "Level : \(current_assessment?.level ?? 3)"
        assessmntNotesLabel.text = "NOTE : \(current_assessment?.notes ?? "")"
        
        //adding progress circle with average count
        var totalProgress = 0
        var progressPercent: CGFloat = 0.0
        let taskCount = self.fetchedResultsController.fetchedObjects?.count ?? 0
        if taskCount > 0 {
            for task in (self.fetchedResultsController.fetchedObjects)! {
                totalProgress += Int(task.progress)
            }
            progressPercent = CGFloat(totalProgress)/CGFloat(taskCount)/100.0
            shapeCompleteLayer.strokeEnd = progressPercent
            self.percentageLable.text = "\(Int(progressPercent * 100))%"
            //change color to blue or red if its above 75 or less
            if Int(progressPercent * 100) <= 75 {
                shapeCompleteLayer.strokeColor = UIColor.init(red: 0/255, green: 122/255, blue: 255/255, alpha: 1).cgColor
            }else{
                shapeCompleteLayer.strokeColor = UIColor.red.cgColor
            }
            //animate the progress circle
            animateCircle()
        }
        
        if current_assessment?.due != nil{
            let currentDate = Date()
            let diff = Calendar.current.dateComponents([.day, .hour, .minute], from: currentDate, to: current_assessment!.due!)
            daysCountLable.text = "\(diff.day!)d \(diff.hour!)h \(diff.minute!)m";
            
            //make text color red after due the end date
            if (currentDate > current_assessment!.due!) {
                daysCountLable.textColor = UIColor.red
            }
            
            let total = (current_assessment!.due!).timeIntervalSince1970 - (current_assessment!.start!).timeIntervalSince1970
            let current = (current_assessment!.due!).timeIntervalSince1970 - Date().timeIntervalSince1970
            
            let timeleftpercentage = (CGFloat(current / total) * 100)
            let showingpercentage = (100 - timeleftpercentage) / 100
            shapeDaysLeftLayer.strokeEnd = showingpercentage
            //change color to blue or red if its above 75 or less
            if Int(showingpercentage) <= 75 {
                shapeDaysLeftLayer.strokeColor = UIColor.init(red: 0/255, green: 122/255, blue: 255/255, alpha: 1).cgColor
            }else{
                shapeDaysLeftLayer.strokeColor = UIColor.red.cgColor
            }
            
            //animate the time circle
            animateSecondCircle()
        }
        
    }
    
    //create the percentage circle
    private func setPercentageCircles() {
        
        //progress track circle
        let tracklayer = createCircleShapeLayer(strokeColor: UIColor.lightGray, fillColor: UIColor.clear, position:assmntCompletePosition)
        view.layer.addSublayer(tracklayer)
        
        shapeCompleteLayer = createCircleShapeLayer(strokeColor:UIColor.red, fillColor:UIColor.clear, position:assmntCompletePosition)
        
        //progress circle
        //TO get into 12'clock top
        shapeCompleteLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeCompleteLayer.strokeEnd = 0
        
        //set lables of the percentage
        percentageLable.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let percentageLablePosition = CGPoint(x: 132, y: 110)
        percentageLable.center = percentageLablePosition
        view.addSubview(percentageLable)
        
        completeLable.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let completeLablePosition = CGPoint(x: 132, y: 135)
        completeLable.center = completeLablePosition
        view.addSubview(completeLable)
        
        view.layer.addSublayer(shapeCompleteLayer)
        
    }
    
    //create the days left circle
    private func setDaysLeftCircles(){
        
        let trackDaysLayer = createCircleShapeLayer(strokeColor: UIColor.lightGray, fillColor: UIColor.clear, position: assmntDaysLefttPosition)
        view.layer.addSublayer(trackDaysLayer)
        
        shapeDaysLeftLayer = createCircleShapeLayer(strokeColor: UIColor.red, fillColor: UIColor.clear, position: assmntDaysLefttPosition)
        
        //progress circle days left
        //TO get into 12'clock top
        shapeDaysLeftLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeDaysLeftLayer.strokeEnd = 0
        
        //set lables of the percentage
        daysCountLable.frame = CGRect(x: 0, y: 0, width: 150, height: 100)
        let percentageLablePosition = CGPoint(x: 850, y: 110)
        daysCountLable.center = percentageLablePosition
        view.addSubview(daysCountLable)
        
        daysLeftLable.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let completeLablePosition = CGPoint(x: 850, y: 135)
        daysLeftLable.center = completeLablePosition
        view.addSubview(daysLeftLable)
        
        view.layer.addSublayer(shapeDaysLeftLayer)
        
    }
    
    // get values to create circles
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor, position: CGPoint) -> CAShapeLayer{
        
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.position = position
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.lineCap = CAShapeLayerLineCap.round
        layer.fillColor = fillColor.cgColor
        return layer
    }
    
    //animate the percentage circle
    private func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        //basicAnimation.toValue = 1
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeCompleteLayer.add(basicAnimation, forKey: "endStrokeKey")
        
    }
    
    //animate the time left circle
    private func animateSecondCircle(){
        let basicAnimationdays = CABasicAnimation(keyPath: "strokeEnd")
        
        //basicAnimation.toValue = 1
        basicAnimationdays.duration = 2
        
        basicAnimationdays.fillMode = CAMediaTimingFillMode.forwards
        basicAnimationdays.isRemovedOnCompletion = false
        
        shapeDaysLeftLayer.add(basicAnimationdays, forKey: "endStrokeKeyofday")
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
        
        if (self.current_assessment != nil) {
            let predicate = NSPredicate(format: "taskAssessment = %@", current_assessment!)
            fetchRequest.predicate = predicate
        } else {
            //TODO: Handle display when a coursework is not selected
        }
        
        let aFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: contex,
            sectionNameKeyPath: #keyPath(Task.assessment),
            cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return aFetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult> as! NSFetchedResultsController<Task>
    }
    
}
