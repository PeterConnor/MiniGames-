//
//  Extensions.swift
//  BrickBreaker
//
//  Created by Pete Connor on 4/5/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import Foundation
import SpriteKit

extension CGFloat {
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
}
