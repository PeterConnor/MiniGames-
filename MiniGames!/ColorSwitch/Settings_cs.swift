//
//  Settings.swift
//  ColorSwitch
//
//  Created by Pete Connor on 2/10/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//cs

import SpriteKit

enum PhysicsCategories_cs {
    static let none: UInt32 = 0
    static let ballCategory: UInt32 = 0x1 // 01
    static let switchCategory: UInt32 = 0x1 << 1 // 10
    static let edgeCategory: UInt32 = 0x1 << 2
    
}

enum ZPositions_cs {
    static let label: CGFloat = 0
    static let ball: CGFloat = 1
    static let colorSwitch: CGFloat = 2
}
