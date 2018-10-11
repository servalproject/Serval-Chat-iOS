//
//  CustomMessageCell.swift
//  Serval Chat
//
//  Created by Alexandre Dorys-Charnalet on 17/09/2018.
//  Copyright © 2018 Alexandre Dorys-Charnalet. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    @IBOutlet weak var senderUsername: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var senderAvatar: UIImageView!
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var leftCellConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightCellConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
