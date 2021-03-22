//
//  TriggerCellTableViewCell.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/22/21.
//

import UIKit

class TriggerCellTableViewCell: UITableViewCell {

    @IBOutlet weak var securityImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        securityImage.transform = securityImage.transform.rotated(by: .pi / 2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
