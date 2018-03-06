//
//  ContentTextView.swift
//  NoticeMe
//
//  Created by 管 皓 on 2018/3/3.
//  Copyright © 2018年 Hao Guan. All rights reserved.
//

import UIKit

class ContentTextView: UITextView {
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setAlpha(0.5)
        let numberOfLines = (self.contentSize.height + self.bounds.size.height) / self.font!.lineHeight
        let baselineOffset: CGFloat = 5.0
        for i in 1...Int(numberOfLines) {
            context.move(to: CGPoint(x: self.bounds.origin.x, y: self.font!.lineHeight * CGFloat(i) + baselineOffset))
            context.addLine(to: CGPoint(x: self.bounds.size.width, y: self.font!.lineHeight * CGFloat(i) + baselineOffset))
        }
        context.closePath()
        context.strokePath()
    }
}
