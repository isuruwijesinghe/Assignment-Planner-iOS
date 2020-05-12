//
//  AssessmentListTableViewCell.swift
//  Assesment-Planner
//
//  Created by Isuru Wijesinghe on 5/11/2563 BE.
//  Copyright © 2563 BE Isuru Wijesinghe. All rights reserved.
//

import UIKit

class AssessmentListTableViewCell: UITableViewCell {
    @IBOutlet weak var assmntNameLabel: UILabel!
    @IBOutlet weak var assmntModuleLabel: UILabel!
    @IBOutlet weak var assmntDueDateLabel: UILabel!
    @IBOutlet weak var assmntDueTimeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
