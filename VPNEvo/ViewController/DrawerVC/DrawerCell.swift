//
//  DrawerCell.swift
//  VPNEvo
//
//  Created by Rootways on 14/03/22.
//

import UIKit

class DrawerCell: UITableViewCell {

    @IBOutlet var imgView:UIImageView!
    @IBOutlet var LabelOption:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
