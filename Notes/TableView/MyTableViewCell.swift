//
//  MyTableViewCell.swift
//  Notes
//
//  Created by Tianid on 14/07/2019.
//  Copyright © 2019 tianid. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {

    @IBOutlet weak var noteColor: UIView!
    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var noteContent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
