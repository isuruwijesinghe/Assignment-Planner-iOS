//
//  TaskTableViewCell.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/12/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskNoteLabel: UILabel!
    @IBOutlet weak var taskProgressSlider: UISlider!
    @IBOutlet weak var taskProgCompleteLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var timeProgressBar: UIProgressView!
    
    var shapeCompleteProgCircleLayer = CAShapeLayer()
    let completeProgCirclePosition = CGPoint(x: 852, y: 86)
    
    let percentageLable: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 22)
        return label
    }()
    
    var task: Task?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //circle to progress
        setPercentageCircles()
        
        //progress bar init radius
        timeProgressBar.transform = timeProgressBar.transform.scaledBy(x: 1, y: 2)
        self.timeProgressBar.layer.cornerRadius = 10.0
        self.timeProgressBar.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        taskNameLabel.text = task?.name
        taskNoteLabel.text = task?.notes
        //set progressar values
        setProgressValues(progress: task?.progress ?? 0)
        
        
        if (task?.start != nil && task?.due != nil) {
            let calendar = Calendar.current
            let unitFlags = Set<Calendar.Component>([ .second])
            var datecomponenets = calendar.dateComponents(unitFlags, from: (task?.start)!, to: Date())
            let timeElapsed = Float(datecomponenets.second!)
            
            datecomponenets = calendar.dateComponents(unitFlags, from: (task?.start)!, to: (task?.due)!)
            let length = Float(datecomponenets.second!)
            
            let elapsedPercentage = (timeElapsed/length)
            
            timeProgressBar.progressTintColor = UIColor.init(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            timeProgressBar.progress = elapsedPercentage
            
            //if the time is due shows in red
            if (elapsedPercentage > 1) {
                remainingTimeLabel.textColor = UIColor.red
                timeProgressBar.progressTintColor = UIColor.red
            }
            
            
            let elapsedTime = Calendar.current.dateComponents([.day, .hour], from: (task?.start)!, to: Date())
            let taskLength = Calendar.current.dateComponents([.day, .hour], from: (task?.start)!, to: (task?.due)!)
            remainingTimeLabel.text = "\(elapsedTime.day!) days, \(elapsedTime.hour!) hours elapsed of \(taskLength.day!) days, \(taskLength.hour!) hours"
            
        }
    }
    
    // the progress slider value changed and save to core data
    @IBAction func progressValueChnaged(_ sender: UISlider) {
        let value = Double(sender.value)
        taskProgCompleteLabel.text = "\(Int(value))% completed"
        percentageLable.text = "\(Int(value))%"
        
        task?.progress = value
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        let progValueToFload = CGFloat(value) / 100
        shapeCompleteProgCircleLayer.strokeEnd = CGFloat(progValueToFload)
        animateCircle()
    }
    
    // create circles to show percentages
    func setPercentageCircles(){
        
        //progress track circle
        let tracklayer = createCircleShapeLayer(strokeColor: UIColor.lightGray, fillColor: UIColor.clear, position:completeProgCirclePosition)
        layer.addSublayer(tracklayer)
        
        //pregress circle
        shapeCompleteProgCircleLayer = createCircleShapeLayer(strokeColor:UIColor.red, fillColor:UIColor.clear, position:completeProgCirclePosition)
        //TO get into 12'clock top
        shapeCompleteProgCircleLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeCompleteProgCircleLayer.strokeEnd = 0
        
        //set lables of the percentage
        percentageLable.frame = CGRect(x: 0, y: 0, width: 75, height: 55)
        let percentageLablePosition = CGPoint(x: 852, y: 86)
        percentageLable.center = percentageLablePosition
        addSubview(percentageLable)
        
        layer.addSublayer(shapeCompleteProgCircleLayer)
    }
    
    //set values to create circles
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor, position: CGPoint) -> CAShapeLayer{
        
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 55, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.position = position
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.lineCap = CAShapeLayerLineCap.round
        layer.fillColor = fillColor.cgColor
        return layer
    }
    
    // circle animation to fill
    private func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        //        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeCompleteProgCircleLayer.add(basicAnimation, forKey: "endStrokeKey")
        
    }
    
    //set progress bar values and call animation
    func setProgressValues(progress: Double){
        
        taskProgCompleteLabel.text = "\(Int(progress))% completed"
        percentageLable.text = "\(Int(progress))%"
        taskProgressSlider.setValue(Float(progress), animated: true)
        
        //change color to blue or red if its above 75 or less
        if Int(progress) <= 75 {
            shapeCompleteProgCircleLayer.strokeColor = UIColor.init(red: 0/255, green: 122/255, blue: 255/255, alpha: 1).cgColor
        }else{
            shapeCompleteProgCircleLayer.strokeColor = UIColor.red.cgColor
        }
        
        let progValueToFload = CGFloat(progress) / 100
        shapeCompleteProgCircleLayer.strokeEnd = CGFloat(progValueToFload)
        
        animateCircle()
        
        
    }
}
