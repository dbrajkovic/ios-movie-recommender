//
//  StarControl.swift
//  movie-rec
//
//  Created by Eric Drew on 3/15/16.
//  Copyright © 2016 Eric Drew. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
class StarControl: UIControl {
    private var starAr = [UIImageView]()
    private var starCount: CGFloat = 0.0
    private var beginPoint: CGPoint?
    private let numStars: Int = 5
    
    var StarCount: CGFloat {
        return starCount
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    func initAr() {
        print("here")
        starAr = []
        let emptyStar = UIImage(named: "star-empty-white")
        let padding = (self.bounds.width - (self.bounds.height * CGFloat(numStars))) / CGFloat(numStars)
        for i in 0...numStars - 1 {
            let rect = CGRectMake(CGFloat(i) * (self.bounds.height + padding) + (padding/2), 0.0, self.bounds.height, self.bounds.height)
            let star = UIImageView(frame: rect)
            if i < Int(starCount) {
                star.image = UIImage(named: "star-full-white")
            } else if CGFloat(i) < starCount {
                star.image = UIImage(named: "star-half-white")
            } else {
                star.image = emptyStar
            }
            starAr.append(star)
        }
    }
    
    override func drawRect(rect: CGRect) {
        initAr()
        self.layer.sublayers = nil
        setNeedsDisplay()
        for star in starAr {
            addSubview(star)
        }
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        beginPoint = touch.locationInView(self)
        return true
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = min(max(0.0, touch.locationInView(self).x), self.bounds.width)
            coordToStar(currentPoint)
        }
    }
    
    func coordToStar(point: CGFloat) {
        let padding = (self.bounds.width - (self.bounds.height * CGFloat(numStars))) / CGFloat(numStars)
        var str = point / (self.bounds.height + padding)
        str = round(str * 2) / 2
        starCount = str
        setNeedsDisplay()
    }


}
