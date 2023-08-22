//
//  myTableViewCell.swift
//  BLEDemoApp
//
//  Created by Shreya Naik on 17/08/23.
//

import UIKit

class BleTableViewCell: UITableViewCell {
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var connectBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
