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
    let completeProgCirclePosition = CGPoint(x: 812, y: 86)
    
    let percentageLable: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    var task: Task?
    
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
        
        setProgressValues(progress: task?.progress ?? 0)
        
        
        if (task?.start != nil && task?.due != nil) {
            let calendar = Calendar.current
            let unitFlags = Set<Calendar.Component>([ .second])
            var datecomponenets = calendar.dateComponents(unitFlags, from: (task?.start)!, to: Date())
            let timeElapsed = Float(datecomponenets.second!)
            
            datecomponenets = calendar.dateComponents(unitFlags, from: (task?.start)!, to: (task?.due)!)
            let length = Float(datecomponenets.second!)
            
            let elapsedPercentage = (timeElapsed/length)
            
            timeProgressBar.progressTintColor = UIColor.green
            timeProgressBar.progress = elapsedPercentage
            
            if (elapsedPercentage > 1) {
                remainingTimeLabel.textColor = UIColor.red
                timeProgressBar.progressTintColor = UIColor.red
            }
            
            
            
            let elapsedTime = Calendar.current.dateComponents([.day, .hour], from: (task?.start)!, to: Date())
            let taskLength = Calendar.current.dateComponents([.day, .hour], from: (task?.start)!, to: (task?.due)!)
            remainingTimeLabel.text = "\(elapsedTime.day!) days, \(elapsedTime.hour!) hours elapsed of \(taskLength.day!) days, \(taskLength.hour!) hours"
            
        }
    }
    @IBAction func editButtonClick(_ sender: Any) {
        
    }
    
   
    
    @IBAction func progressValueChnaged(_ sender: UISlider) {
        let value = Int16(sender.value)
        taskProgCompleteLabel.text = "\(value)% completed"
        percentageLable.text = "\(value)%"
        task?.progress = value
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        let progValueToFload = CGFloat(value) / 100
        shapeCompleteProgCircleLayer.strokeEnd = CGFloat(progValueToFload)
        animateCircle()
    }
    
    func setPercentageCircles(){
        //progress track circle
        let tracklayer = createCircleShapeLayer(strokeColor: UIColor.lightGray, fillColor: UIColor.clear, position:completeProgCirclePosition)
        layer.addSublayer(tracklayer)
        
        shapeCompleteProgCircleLayer = createCircleShapeLayer(strokeColor:UIColor.red, fillColor:UIColor.clear, position:completeProgCirclePosition)
        
        //progress circle
        //TO get into 12'clock top
        shapeCompleteProgCircleLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeCompleteProgCircleLayer.strokeEnd = 0
        
        //set lables of the percentage
        percentageLable.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        let percentageLablePosition = CGPoint(x: 812, y: 86)
        percentageLable.center = percentageLablePosition
        addSubview(percentageLable)
        
        
        layer.addSublayer(shapeCompleteProgCircleLayer)
    }
    
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
    
    private func animateCircle() {
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            
    //        basicAnimation.toValue = 1
            basicAnimation.duration = 2
            
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            
            shapeCompleteProgCircleLayer.add(basicAnimation, forKey: "endStrokeKey")
            
        }
    func setProgressValues(progress: Int16){
        
        taskProgCompleteLabel.text = "\(progress)% completed"
        percentageLable.text = "\(progress)%"
        
        taskProgressSlider.setValue(Float(progress), animated: true)
        
        let progValueToFload = CGFloat(progress) / 100
        shapeCompleteProgCircleLayer.strokeEnd = CGFloat(progValueToFload)
        animateCircle()
        
        
    }
}
