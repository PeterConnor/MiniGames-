//
//  Random.swift
//  FlappyBird
//
//  Created by Pete Connor on 4/21/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import Foundation
import CoreGraphics

public extension CGFloat {
    
    public static func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + firstNum
    }
    
}
