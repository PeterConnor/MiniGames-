//
//  MenuScene.swift
//  BrickBreaker
//
//  Created by Pete Connor on 3/25/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//
import Foundation
import SpriteKit
import GameKit

class MenuScene_bb: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
    
    var leaderButton: SKSpriteNode!
    
    var playLabel: SKLabelNode!
    
    var backButton: SKSpriteNode!
    var infoButton: SKSpriteNode!
    
    var recentScoreLabel = SKLabelNode()
    
    weak var gameVC: GameViewController2?
    
    override func didMove(to view: SKView) {
        

        ballSpeedX = frame.size.width * 0.067
        ballSpeedY = frame.size.width * 0.067
        
        addLabels()
        addBackButton()
        addInfoButton()
        
        backgroundColor = .darkGray
        
        ballSpeed = CGVector(dx: ballSpeedX, dy: ballSpeedY)
        
        self.physicsWorld.contactDelegate = self
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        let border = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody = border
        physicsBody?.friction = 0
        
        paddle = SKSpriteNode(imageNamed: "bbpaddle")
        paddle.name = paddleCategoryName
        if UIDevice.current.userInterfaceIdiom == .pad {
            paddle.position = CGPoint(x: frame.midX, y: leaderButton.position.y - paddle.frame.size.height * 4.0)
        } else {
            paddle.position = CGPoint(x: frame.midX, y: recentScoreLabel.position.y - recentScoreLabel.frame.size.height)
        }
        
        
        
        ball = SKSpriteNode(imageNamed: "bbball")
        ball.size = CGSize(width: frame.size.width/25, height: frame.size.width/25)
        ball.name = ballCategoryName
        ball.position = CGPoint(x: frame.midX, y: (paddle.position.y) + ball.size.height)
        
        paddle.size = CGSize(width: ball.size.width*5, height: ball.size.width)
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
        ball.physicsBody?.mass = 0.00785398203879595

        
        let bottomRect = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        
        self.addChild(bottom)
        
        bottom.physicsBody?.categoryBitMask = bottomCategory
        ball.physicsBody?.categoryBitMask = ballCategory
        paddle.physicsBody?.categoryBitMask = paddleCategory
        ball.physicsBody?.collisionBitMask = paddleCategory | brickCategory | bottomCategory
        ball.physicsBody?.contactTestBitMask = bottomCategory | brickCategory
        
        setupBricks()
        
        ball.physicsBody?.applyImpulse(CGVector(dx: 2, dy: 2))
        
        
        
    }
    func addBackButton() {
        backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        backButton.size.width = frame.size.width/10
        backButton.size.height = backButton.size.width
        backButton.position = CGPoint(x: frame.minX + backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 20)
        backButton.zPosition = 6
    
        addChild(backButton)
        backButton.color = .white
        backButton.colorBlendFactor = 1.0
    }
    
    func addInfoButton() {
        infoButton = SKSpriteNode(texture: SKTexture(imageNamed: "InfoButtonWhite"))
        infoButton.name = "InfoButton"
        infoButton.size.width = frame.size.width/10
        infoButton.size.height = infoButton.size.width
        infoButton.position = CGPoint(x: frame.maxX - backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 20)
        infoButton.zPosition = 6
        
        addChild(infoButton)
    }
    
    func addLabels() {
        playLabel = SKLabelNode(text: "Tap here to Play!")
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontSize = 30.0
        playLabel.fontColor = UIColor.white
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(playLabel)
        animate(label: playLabel)
        
        let highscoreLabel = SKLabelNode(text: "High Score: \(UserDefaults.standard.integer(forKey: "HighScore_bb"))")
        highscoreLabel.fontName = "AvenirNext-Bold"
        highscoreLabel.fontSize = 30.0
        highscoreLabel.fontColor = UIColor.white
        highscoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - highscoreLabel.frame.size.height*3)
        addChild(highscoreLabel)
        
        recentScoreLabel = SKLabelNode(text: "Recent Score: \(UserDefaults.standard.integer(forKey: "RecentScore_bb"))")
        recentScoreLabel.fontName = "AvenirNext-Bold"
        recentScoreLabel.fontSize = 30.0
        recentScoreLabel.fontColor = UIColor.white
        recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height*2)
        addChild(recentScoreLabel)
        addLeaderButton()
    }
    
    func animate(label: SKLabelNode) {
        //let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        //let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        
        //let sequence = SKAction.sequence([fadeOut, fadeIn])
        let sequence2 = SKAction.sequence([scaleUp, scaleDown])
        label.run(SKAction.repeatForever(sequence2))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let gameScene = GameScene_bb(fileNamed: "GameScene_bb")
        if let touch = touches.first {
            let location = touch.location(in: self)
            if let playLabel = self.playLabel {
                if playLabel.contains(location) {
                    gameScene?.gameVC = gameVC
                    gameScene?.scaleMode = .aspectFit
                    gameScene?.backgroundColor = .white
                    view!.presentScene(gameScene)
                    

                }
            }
            if backButton.contains(location) {
                gameVC?.dismiss(animated: true, completion: nil)
            }
            
            if leaderButton.contains(location) {
                showLeader()
            }
            
            if infoButton.contains(location) {
                showAlert()
            }
        }
    }
    var lifeBool = true
    
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
    
    var brickCount = 24
    
    var ballSpeed: CGVector!
    var ballSpeedX: CGFloat = 0
    var ballSpeedY: CGFloat = 0
    var ballSpeedMultiplier = 1.0
    
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
                    switch y {
                    case 1:
                        return self.frame.size.height - padding*7
                    case 2:
                        return self.frame.size.height - (padding*8) - brick.size.height
                    case 3:
                        return self.frame.size.height - (padding*9) - (brick.size.height*2)
                    case 4:
                        return self.frame.size.height - (padding*10) - (brick.size.height*3)
                        
                        
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
            brickCount -= 1
            if brickCount == 0 {
                ball.physicsBody?.categoryBitMask = nilCategory
                ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                ball.run(SKAction.move(to: CGPoint(x: frame.midX, y: (paddle.frame.size.height * 2) + 30), duration: 0.01))
                paddle.run(SKAction.move(to: CGPoint(x: frame.midX, y: paddle.frame.size.height * 2), duration: 0.01))
                brickCount = 24
                ballSpeedMultiplier += 0.1
                gameState = GameState_bb.touchToBegin
                setupBricks()
            }
            
            if didWin() {
                //you win
            }
        }
        
    }
    
    func didWin() -> Bool {
        var numberOfBricks = 0
        for nodeObject in self.children {
            let node = nodeObject as SKNode
            if node.name == brickCategoryName {
                numberOfBricks += 1
            }
        }
        return numberOfBricks <= 0
        }
    
    func addLeaderButton() {
        leaderButton = SKSpriteNode(texture: SKTexture(imageNamed: "LeaderButton"))
        leaderButton.name = "BackButton"
        leaderButton.size.width = frame.size.width/15
        leaderButton.size.height = leaderButton.size.width
        leaderButton.position = CGPoint(x: frame.midX, y: recentScoreLabel.frame.minY - leaderButton.size.height * 1.5)
        leaderButton.size = CGSize(width: leaderButton.size.height*2.2, height: frame.size.width/10)
        leaderButton.zPosition = 6
        
        addChild(leaderButton)
    }
    
    func showLeader() {
        
        submitScore()
        
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "MiniGames! - Brick Breaker"
        gameVC?.present(gcVC, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore() {
        let leaderboardID = "MiniGames! - Brick Breaker"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(UserDefaults.standard.integer(forKey: "HighScore_bb"))
        //let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        GKScore.report([sScore]) { (error: Error!) -> Void in
            if error != nil {
                print(error.localizedDescription)
            } else {
                print("Score Submitted")
                
            }
        }
        
    }
    
    func showAlert() {
        let myAlert: UIAlertController = UIAlertController(title: "Instructions", message: "Drag your finger across the bottom of the screen to move the paddle. Hit the bricks with the ball to earn points, but don't let the ball go below the paddle!", preferredStyle: .alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        gameVC?.present(myAlert, animated: true, completion: nil)
    }
    
    }
