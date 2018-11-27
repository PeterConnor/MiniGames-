import SpriteKit

var minX = CGFloat(-325)
var maxX = CGFloat(325)

class Player_gs: SKSpriteNode {
    
    func initializePlayer() {
        name = "Player"
        position.y += 50
        zPosition = 4
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        /*physicsBody = SKPhysicsBody(texture: self.texture!, size: CGSize(width: view.frame.size.width*0.25, height: size.width*1.75))        //physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width - CGFloat(20), height: self.size.height - CGFloat(15)))
         physicsBody?.affectedByGravity = false
         physicsBody?.isDynamic = false
         physicsBody?.categoryBitMask = ColliderType_gs.Player
         physicsBody?.contactTestBitMask = ColliderType_gs.FruitAndBomb*/
    }
    
    func move(left: Bool) {
        //let moveAction = SKAction.run {
        if left {
            self.position.x -= 15
            
            if self.position.x < minX {
                self.position.x = minX
            }
        } else {
            self.position.x += 15
            if self.position.x > maxX {
                self.position.x = maxX
            }
        }
        //}
        //self.run(moveAction)
        
    }
    
}
