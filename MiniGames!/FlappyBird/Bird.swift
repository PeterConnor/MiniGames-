//
//  Bird.swift
//  FlappyBird
//
//  Created by Pete Connor on 4/18/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import SpriteKit

struct ColliderType {
    static let Bird: UInt32 = 1
    static let Ground: UInt32 = 2
    static let Pipes: UInt32 = 3
    static let Score: UInt32 = 4
}

class Bird: SKSpriteNode {
    
    var birdAnimation = [SKTexture]()
    var birdAnimationAction = SKAction()
    
    var diedTexture = SKTexture()
    
    func initialize() {
        
        for i in 1..<3 {
            let name = "\(GameManager.instance.getBird()) \(i)"
            birdAnimation.append(SKTexture(imageNamed: name))
        }
        
        birdAnimationAction = SKAction.animate(with: birdAnimation, timePerFrame: 0.03, resize: true, restore: true)
        
        diedTexture = SKTexture(imageNamed: "Blue 4")
        
        self.name = "Bird"
        self.zPosition = 3
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/2)
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = ColliderType.Bird
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Pipes
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.Pipes | ColliderType.Score
    }
    
    func flap() {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))
        self.run(birdAnimationAction)
        self.run(SKAction.sequence([birdAnimationAction, birdAnimationAction, birdAnimationAction, birdAnimationAction, birdAnimationAction])) {
            self.texture = SKTexture(imageNamed: "Blue 1")
        }
        
    }
    
}
