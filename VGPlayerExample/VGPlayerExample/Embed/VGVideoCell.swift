//
//  VGVideoCell.swift
//  VGPlayerExample
//
//  Created by Vein on 2017/8/9.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit

class VGVideoCell: UITableViewCell {

    var playCallBack:((IndexPath?) -> Swift.Void)?
    var indexPath : IndexPath?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func onPlay(_ sender: Any) {
        if let callBack = playCallBack {
            callBack(indexPath)
        }
    }
}
