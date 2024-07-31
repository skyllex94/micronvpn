//
//  CountryCell.swift
//  StreamVPN
//
//  Created by Vishal Sagar on 11/02/22.
//

import UIKit

class CountryCell: UITableViewCell {

    @IBOutlet var countryView:UIView!
    
    @IBOutlet var countyImg:UIImageView!
    @IBOutlet var LabelCountryName:UILabel!
    @IBOutlet var signalImg:UIImageView!
    @IBOutlet var checkMarkImg:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        countryView.layer.cornerRadius = 10.0
        countryView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
