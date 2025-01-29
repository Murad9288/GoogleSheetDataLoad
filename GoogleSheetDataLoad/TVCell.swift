//
//  TVCell.swift
//  GoogleSheetDataLoad
//
//  Created by MD Murad Hossain on 1/30/25.
//

import UIKit

class TVCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    // MARK: - Properties
    static let identifier: String = "TVCell"
    static func nib() -> UINib {
        return UINib(nibName: "TVCell", bundle: nil)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
