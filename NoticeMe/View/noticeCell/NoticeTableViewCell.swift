//
//  NoticeCellTableViewCell.swift
//  NoticeMe
//
//  Created by 管 皓 on 2018/2/17.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit
import SwipeCellKit


@IBDesignable class NoticeTableViewCell: SwipeTableViewCell {
    
    
    @IBOutlet var updateTimeTextView: UITextView!
    @IBOutlet var noticeName: UILabel!
    @IBOutlet var markButtonOutlet: UIButton!
    var markButtonPressedCallback: (() throws-> ())?
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth  = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @IBAction func markedButtonPressed(_ sender: UIButton) {
        do {
            try markButtonPressedCallback?()
        } catch {
            print(error)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
