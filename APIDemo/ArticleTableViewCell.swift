//
//  ArticleTableViewCell.swift
//  APIDemo
//
//  Created by Lun Sovathana on 11/30/16.
//  Copyright © 2016 Lun Sovathana. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {
 
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // change label font
        title.font = UIFont(name: "Kh-Battambang", size: 17)
        author.font = UIFont(name: "Kh-Battambang", size: 15)
        desc.font = UIFont(name: "Kh-Battambang", size: 14)
        
        author.layer.cornerRadius = author.bounds.height/2
        author.layer.masksToBounds = true
        author.textAlignment = .center
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
