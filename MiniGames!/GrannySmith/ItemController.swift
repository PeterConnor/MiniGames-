import SpriteKit

struct ColliderType_gs {
    static let Player: UInt32 = 0
    static let FruitAndBomb: UInt32 = 1
}

class ItemController {
    
    func spawnItems() -> SKSpriteNode {
        
        let item: SKSpriteNode?
        
        
        if Int(randomBetweenNumbers(firstNum: 0, secondNum: 10)) >= 6 {
            let num = Int(randomBetweenNumbers(firstNum: 1, secondNum: 3))
            item = SKSpriteNode(imageNamed: "Apple\(num)")
            item!.name = "Fruit"
        } else {
            item = SKSpriteNode(imageNamed: "Apple3")
            item!.name = "Bomb"
        }
        item?.size.width = 100
        item?.size.height = 100
        item?.physicsBody?.categoryBitMask = ColliderType_gs.FruitAndBomb
        item?.zPosition = 3
        item?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //item!.physicsBody = SKPhysicsBody(circleOfRadius: item!.size.height/2)
        item?.physicsBody = SKPhysicsBody(texture: (item?.texture)!, size: CGSize(width: (item?.size.width)! * 0.95, height: (item?.size.height)! * 0.95))
        item?.physicsBody?.allowsRotation = false
        
        
        item?.position.x = randomBetweenNumbers(firstNum: minX, secondNum: maxX)
        item?.position.y = 700
        
        return item!
        
    }
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        
        
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
        
        
    }
    
}
