//
//  TrainsCell.swift
//  Exercise
//
//  Created by Sunil Kumar on 10/03/19.
//  Copyright © 2019 Test. All rights reserved.
//

import UIKit

class TrainsCell: UITableViewCell {
    @IBOutlet weak var trainName: UILabel!
    @IBOutlet weak var trainCode: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
