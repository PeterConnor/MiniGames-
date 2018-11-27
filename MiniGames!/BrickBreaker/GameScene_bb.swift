//
//  GameScene.swift
//  BrickBreaker
//
//  Created by Pete Connor on 3/14/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import SpriteKit
import GameplayKit

enum GameState_bb {
    case touchToBegin
    case playing
    case gameOver
}

class GameScene_bb: SKScene, SKPhysicsContactDelegate {
    
    weak var gameVC: GameViewController2?
    
    var isGamePaused = false
    
    var pauseButton = SKSpriteNode()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var lives: Int = 3 {
        didSet {
            livesLabel.text = "Lives: \(lives)"
        }
    }
    
    var lifeBool = true
    var paddleMove = true
    
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var speedLabel: SKLabelNode!
    
    let ballCategoryName = "ball"
    let paddleCategoryName = "paddle"
    let brickCategoryName = "brick"
    
    let ballCategory: UInt32 = 0x1 << 0
    let bottomCategory: UInt32 = 0x1 << 1
    let brickCategory: UInt32 = 0x1 << 2
    let paddleCategory: UInt32 = 0x1 << 3
    let nilCategory: UInt32 = 0x1 << 4
    
    var gameState: GameState_bb!
    
    var ball: SKSpriteNode!
    var paddle: SKSpriteNode!
    var backButton: SKSpriteNode!
    
    var brickCount = 24
    
    var ballSpeed: CGVector!
    var ballSpeedX: CGFloat = 0.0
    var ballSpeedY: CGFloat = 0.0
    var ballSpeedMultiplier = 1.0 {
        didSet {
            speedLabel.text = ("Speed: \(ballSpeedMultiplier)")
        }
    }

        override func didMove(to view: SKView) {
            print(self.size)
            
            NotificationCenter.default.addObserver(self, selector: #selector(GameScene_bb.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
            
            ballSpeedX = 200.0
            ballSpeedY = 200.0
            print(ballSpeedX, ballSpeedY)
            
            addPauseButton()
            backgroundColor = .darkGray
            
            let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
            backButton.name = "BackButton"
            backButton.size.width = frame.size.width/10
            backButton.size.height = backButton.size.width
            backButton.position = CGPoint(x: frame.minX + backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 20)
            backButton.zPosition = 6
            
            
            addChild(backButton)
            backButton.color = .white
            backButton.colorBlendFactor = 1.0
            
            ballSpeed = CGVector(dx: ballSpeedX, dy: ballSpeedY)

            
            gameState = GameState_bb.touchToBegin
            
            
        
            //scoreLabel.frame.size.height = speedLabel.frame.size.height
            scoreLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
            scoreLabel.text = "Score: 0"
            if frame.size.height == 812.0 {
                scoreLabel.position = CGPoint(x: frame.minX + backButton.size.width * 1.5, y: frame.maxY - 50)
            } else {
                scoreLabel.position = CGPoint(x: frame.minX + backButton.size.width * 1.5, y: frame.maxY - 40)
            }
            scoreLabel.horizontalAlignmentMode = .left

            speedLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
            speedLabel.text = "Speed: 1.0"
            speedLabel.fontSize = 20
            speedLabel.horizontalAlignmentMode = .right

            scoreLabel.fontSize = 20
            
            speedLabel.position = CGPoint(x: frame.maxX - pauseButton.size.width, y: frame.maxY - 40)
            livesLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
            livesLabel.text = "Lives: 3"
            livesLabel.horizontalAlignmentMode = .right
            if frame.size.height == 812.0 {
                livesLabel.position = CGPoint(x: frame.maxX - pauseButton.size.width * 1.5, y: frame.maxY - 50)
            } else {
                livesLabel.position = CGPoint(x: frame.maxX - pauseButton.size.width * 1.5, y: frame.maxY - 40)
            }
            
            livesLabel.fontSize = 20
        
            
            addChild(scoreLabel)
            //addChild(speedLabel)
            addChild(livesLabel)
            
            self.physicsWorld.contactDelegate = self
            
            self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            
            var border = SKPhysicsBody()
            if frame.size.height == 812.0 {
                border = SKPhysicsBody(edgeLoopFrom: CGRect(x: frame.minX, y: frame.minY, width: frame.size.width, height: frame.size.height - 20))
            } else {
                border = SKPhysicsBody(edgeLoopFrom: frame)
            }
            
            physicsBody = border
            physicsBody?.friction = 0
            physicsBody?.density = 0
        
            
            paddle = SKSpriteNode(imageNamed: "bbpaddle")
            paddle.name = paddleCategoryName
            
            ball = SKSpriteNode(imageNamed: "bbball")
            ball.size = CGSize(width: frame.size.width/25, height: frame.size.width/25)
        
            ball.name = ballCategoryName
            
            // CHANGE WIDTH BACK TO ball.size.width*4
            paddle.size = CGSize(width: ball.size.width*5, height: ball.size.width)

            paddle.position = CGPoint(x: frame.midX, y: paddle.frame.size.height * 12 + view.safeAreaInsets.bottom)
            ball.position = CGPoint(x: frame.midX, y: (paddle.position.y) + ball.size.height)
            paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
            paddle.physicsBody?.friction = 0
            paddle.physicsBody?.restitution = 1
            paddle.physicsBody?.isDynamic = false
            
            self.addChild(ball)
            self.addChild(paddle)
            
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
            ball.physicsBody?.friction = 0
            ball.physicsBody?.restitution = 1
            ball.physicsBody?.linearDamping = 0
            ball.physicsBody?.allowsRotation = false
            ball.physicsBody?.usesPreciseCollisionDetection = true
            ball.physicsBody?.isDynamic = false
            ball.physicsBody?.mass = 0.0045

            
            let bottomRect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: 1)
            let bottom = SKNode()
            bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
            
            self.addChild(bottom)
            
            bottom.physicsBody?.categoryBitMask = bottomCategory
            ball.physicsBody?.categoryBitMask = ballCategory
            paddle.physicsBody?.categoryBitMask = paddleCategory
            ball.physicsBody?.collisionBitMask = paddleCategory | brickCategory | bottomCategory
            ball.physicsBody?.contactTestBitMask = bottomCategory | brickCategory | paddleCategory
        
            setupBricks()
            
        
            
            
        
    }
    
    
    func setupBricks() {
        
        let numberOfBricks = 6
        var count = 0
        
        for index in 1...numberOfBricks {
            count += 1
            for y in 1...4 {
                
                let brick = SKSpriteNode(imageNamed: "Brick \(y)")
                brick.size = CGSize(width: ball.size.width*2, height: ball.size.height)
                
                
                let fullPadding = self.frame.size.width - (CGFloat(numberOfBricks) * brick.size.width)
                let padding = fullPadding / (CGFloat(numberOfBricks) + 5.0)
                
                var positionY: CGFloat {
                    let safeArea = view?.safeAreaInsets.bottom ?? 0
                    switch y {
                                            case 1:
                        return self.frame.size.height - padding*7 - safeArea
                    case 2:
                        return self.frame.size.height - (padding*8) - brick.size.height  - safeArea
                    case 3:
                        return self.frame.size.height - (padding*9) - (brick.size.height*2) - safeArea
                    case 4:
                        return self.frame.size.height - (padding*10) - (brick.size.height*3) - safeArea


                    default:
                        return 0.0
                    }
                }
            

                
                var positionX: CGFloat {
                switch count {
                    case 1:
                        return frame.minX + padding * 3
                    case 2:
                        return frame.minX + brick.size.width + (padding * 4)
                    case 3:
                        return frame.minX + (brick.size.width * 2) + (padding * 5)
                    case 4:
                        return frame.minX + (brick.size.width * 3) + (padding * 6)
                    case 5:
                        return frame.minX + (brick.size.width * 4) + (padding * 7)
                    case 6:
                        return frame.minX + (brick.size.width * 5) + (padding * 8)
                    default:
                        return 0
                    
                }
            }
            brick.anchorPoint = CGPoint(x: 0, y: 0)
            brick.position.x = positionX
            
            brick.position.y = positionY
            
            brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: CGPoint(x: brick.size.width/2, y: brick.size.height/2))
            brick.physicsBody?.allowsRotation = false
            brick.physicsBody?.friction = 0
            brick.name = brickCategoryName
            brick.physicsBody?.categoryBitMask = brickCategory
            brick.physicsBody?.isDynamic = false
            self.addChild(brick)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                
                let menuScene = MenuScene_bb(size: view!.bounds.size)
                menuScene.scaleMode = .aspectFill
                menuScene.gameVC = gameVC

                self.view?.presentScene(menuScene, transition: SKTransition.flipHorizontal(withDuration: 1))
            }
            
            if atPoint(location).name == "PauseButton" {
                if isGamePaused == false {
                    self.speed = 0.0
                    self.physicsWorld.speed = 0.0
                    self.isPaused = true
                    isGamePaused = true
                    pauseButton.texture = SKTexture(imageNamed: "PlayButtonWhite")
                } else {
                    isGamePaused = false
                    self.isPaused = false
                    pauseButton.texture = SKTexture(imageNamed: "PauseButtonWhite")
                    self.speed = 1.0
                    self.physicsWorld.speed = 1.0
                }
            }
            
        }
        
        if gameState == GameState_bb.touchToBegin {
            paddleMove = true
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.categoryBitMask = ballCategory
            let num = arc4random_uniform(2)
            gameState = GameState_bb.playing
            ballSpeedY = CGFloat(2 * ballSpeedMultiplier)
            let numX = arc4random_uniform(UInt32(ballSpeedY))
            let doubleNumX = Double(numX)
            let decimal = arc4random_uniform(UInt32(9))
            var doubleDecimal = Double(decimal)
            doubleDecimal = doubleDecimal * 0.1
            if doubleDecimal == 0.0 {
                doubleDecimal += 0.2
            }
            
            ballSpeedX = CGFloat(doubleNumX + doubleDecimal)
            if num == 1 {
                ballSpeedX *= -1
            }
            ballSpeed = CGVector(dx: ballSpeedX, dy: ballSpeedY)

            ball.physicsBody?.applyImpulse(ballSpeed)
        }
        let touch = touches.first
        let touchLocation = touch?.location(in: self)
        
        let body: SKPhysicsBody? = self.physicsWorld.body(at: touchLocation!)
        
        if body?.node?.name == paddleCategoryName {
           // fingerIsOnPaddle = true
        }
    }
    
    @objc func pauseGame() {
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButtonWhite")
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if paddleMove && isGamePaused == false {
            if let touch = touches.first {
                let location = touch.location(in: self)
                let previousTouch = touch.previousLocation(in: self)
                
                let paddle = self.childNode(withName: paddleCategoryName) as! SKSpriteNode

                var newXPosition = paddle.position.x + ((location.x) - (previousTouch.x))
                
                newXPosition = max(newXPosition, paddle.size.width / 2)
                newXPosition = min(newXPosition, self.size.width - paddle.size.width / 2)
                
                paddle.position.x = newXPosition
            }
            /*
            let touch = touches.first
            let touchLocation = touch?.location(in: self)
            let previousTouchLocation = touch?.previousLocation(in: self)
            
            let paddle = self.childNode(withName: paddleCategoryName) as! SKSpriteNode
            
            var newXPosition = paddle.position.x + ((touchLocation?.x)! - (previousTouchLocation?.x)!)
            
            newXPosition = max(newXPosition, paddle.size.width / 2)
            newXPosition = min(newXPosition, self.size.width - paddle.size.width / 2)
            
            paddle.position.x = newXPosition */
        
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //remove this line, so user can click anywhere to move paddle
        //fingerIsOnPaddle = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
            //you lose
        }
            
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == brickCategory {
            secondBody.node?.physicsBody?.categoryBitMask = nilCategory
            let removeAction = SKAction.run {
                secondBody.node?.removeFromParent()
            }
            let waitAction = SKAction.wait(forDuration: 1.0)
            let scaleAction = SKAction.scale(to: 0, duration: 0.25)
            secondBody.node?.run(SKAction.sequence([scaleAction, waitAction, removeAction]))
            //secondBody.node?.removeFromParent()
            score += 1
            brickCount -= 1
            if brickCount == 0 {
                ball.physicsBody?.categoryBitMask = nilCategory
                ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                ball.run(SKAction.move(to: CGPoint(x: frame.midX, y: (paddle.position.y) + ball.size.height), duration: 0.01))
                paddle.run(SKAction.move(to: CGPoint(x: frame.midX, y: paddle.frame.size.height * 12), duration: 0.01))
                brickCount = 24
                ballSpeedMultiplier += 0.1
                gameState = GameState_bb.touchToBegin
                setupBricks()
            }
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory {
            if gameState == GameState_bb.playing {
            //RIGHTS - Furthest Right to Right Mid
                if contact.contactPoint.x > paddle.position.x + paddle.size.width * 0.45  {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY), dy: abs(ballSpeedY)))

                }
                
                if contact.contactPoint.x > paddle.position.x + paddle.size.width * 0.4 && contact.contactPoint.x < paddle.position.x + paddle.size.width * 0.45 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY) * 0.9, dy: abs(ballSpeedY)))

                }
                
                if contact.contactPoint.x > paddle.position.x + paddle.size.width * 0.35 && contact.contactPoint.x < paddle.position.x + paddle.size.width * 0.4 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY) * 0.8, dy: abs(ballSpeedY)))
                }
                
                if contact.contactPoint.x > paddle.position.x + paddle.size.width * 0.3 && contact.contactPoint.x < paddle.position.x + paddle.size.width * 0.35 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY) * 0.7, dy: abs(ballSpeedY)))
                    
                }
                
                if contact.contactPoint.x > paddle.position.x + paddle.size.width * 0.25 && contact.contactPoint.x < paddle.position.x + paddle.size.width * 0.3 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY) * 0.6, dy: abs(ballSpeedY)))
                    
                }
                
                if contact.contactPoint.x > paddle.position.x + paddle.size.width * 0.2 && contact.contactPoint.x < paddle.position.x + paddle.size.width * 0.25{
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY) * 0.5, dy: abs(ballSpeedY)))
                    
                }
                
                if contact.contactPoint.x > paddle.position.x + paddle.size.width * 0.15 && contact.contactPoint.x < paddle.position.x + paddle.size.width * 0.2 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY) * 0.4, dy: abs(ballSpeedY)))
                    
                }
                
                if contact.contactPoint.x > paddle.position.x + paddle.size.width * 0.10 && contact.contactPoint.x < paddle.position.x + paddle.size.width * 0.15 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY) * 0.3, dy: abs(ballSpeedY)))
                    
                }
                
                if contact.contactPoint.x > paddle.position.x + paddle.size.width * 0.05 && contact.contactPoint.x < paddle.position.x + paddle.size.width * 0.10{
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY) * 0.2, dy: abs(ballSpeedY)))
                    
                }
                
                if contact.contactPoint.x > paddle.position.x && contact.contactPoint.x < paddle.position.x + paddle.size.width * 0.05 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: abs(ballSpeedY) * 0.1, dy: abs(ballSpeedY)))
                }
                
                //LEFTS - Furthest left to left mid
                if contact.contactPoint.x < paddle.position.x - paddle.size.width * 0.45 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY), dy: ballSpeedY))
                    

                }
                
                if contact.contactPoint.x < paddle.position.x - paddle.size.width * 0.4 && contact.contactPoint.x > paddle.position.x - paddle.size.width * 0.45 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY) * 0.9, dy: ballSpeedY))
                }
                
                if contact.contactPoint.x < paddle.position.x - paddle.size.width * 0.35 && contact.contactPoint.x > paddle.position.x - paddle.size.width * 0.4 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY) * 0.8, dy: ballSpeedY))
                }
                
                if contact.contactPoint.x < paddle.position.x - paddle.size.width * 0.3 && contact.contactPoint.x > paddle.position.x - paddle.size.width * 0.35 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY) * 0.7, dy: ballSpeedY))
                    
                }
                
                if contact.contactPoint.x < paddle.position.x - paddle.size.width * 0.25 && contact.contactPoint.x > paddle.position.x - paddle.size.width * 0.3 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY) * 0.6, dy: ballSpeedY))
                    
                }
                
                if contact.contactPoint.x < paddle.position.x - paddle.size.width * 0.2 && contact.contactPoint.x > paddle.position.x - paddle.size.width * 0.25 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY) * 0.5, dy: ballSpeedY))
                    
                }
                
                if contact.contactPoint.x < paddle.position.x - paddle.size.width * 0.15 && contact.contactPoint.x > paddle.position.x - paddle.size.width * 0.2 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY) * 0.4, dy: ballSpeedY))
                }
                
                if contact.contactPoint.x < paddle.position.x - paddle.size.width * 0.10 && contact.contactPoint.x > paddle.position.x - paddle.size.width * 0.15 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY) * 0.3, dy: ballSpeedY))
                }
                
                if contact.contactPoint.x < paddle.position.x - paddle.size.width * 0.05 && contact.contactPoint.x > paddle.position.x - paddle.size.width * 0.10 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY) * 0.2, dy: ballSpeedY))
                }
                
                if contact.contactPoint.x < paddle.position.x && contact.contactPoint.x > paddle.position.x - paddle.size.width * 0.05 {
                    ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    ball.physicsBody?.applyImpulse(CGVector(dx: -abs(ballSpeedY) * 0.1, dy: ballSpeedY))
                }
                // MID
                    if contact.contactPoint.x == paddle.position.x  {
                        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                        ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: ballSpeedY))
                    }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if gameState == GameState_bb.touchToBegin  {
            ball.physicsBody?.isDynamic = false
        }
        
        if ball.physicsBody?.velocity.dy == 0.0 {
            var tempNum = -0.05
            let randomNum = arc4random_uniform(2)
            if randomNum == 1 {
                tempNum *= -1
            }
            ball.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: tempNum))
        }
        
            if ball.position.y < paddle.position.y - 5 && lifeBool == true {
                isUserInteractionEnabled = false
                paddleMove = false
                let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
                let actionBack = SKAction.wait(forDuration: 0.5)
                
                self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                    self.run(SKAction.colorize(with: .darkGray, colorBlendFactor: 1.0, duration: 0.01))
                    self.ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    self.ball.run(SKAction.move(to: CGPoint(x: self.frame.midX, y: (self.paddle.position.y) + self.ball.size.height), duration: 0.01))
                    self.paddle.run(SKAction.move(to: CGPoint(x: self.frame.midX, y: self.paddle.frame.size.height * 12), duration: 0.01))
                    self.isUserInteractionEnabled = true
                })
                gameState = GameState_bb.touchToBegin
                lifeBool = false
                if lives > 1 {
                    lives -= 1
                } else {
                    paddleMove = false
                    isUserInteractionEnabled = false
                    let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
                    let actionBack = SKAction.wait(forDuration: 0.5)
                    
                    self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                        self.gameOver()
                    })
                }
            }
        if ball.position.y > paddle.position.y {
            lifeBool = true
        }
    }
    
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "RecentScore_bb")
        if score > UserDefaults.standard.integer(forKey: "HighScore_bb") {
            UserDefaults.standard.set(score, forKey: "HighScore_bb")
        }
        
        let menuScene = MenuScene_bb(size: view!.bounds.size)
        menuScene.gameVC = gameVC

        view!.presentScene(menuScene)
    }
    
    func addPauseButton() {
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "PauseButtonWhite"))
        pauseButton.name = "PauseButton"
        pauseButton.size.width = frame.size.width/10
        pauseButton.size.height = pauseButton.size.width
        pauseButton.position = CGPoint(x: frame.maxX - pauseButton.size.width/2, y: frame.maxY - pauseButton.size.height/2 - 20)
        pauseButton.zPosition = 6
        addChild(pauseButton)
    }
}
