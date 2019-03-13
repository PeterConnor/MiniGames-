//
//  GameScene_bounce.swift
//  MiniGames!
//
//  Created by Pete Connor on 2/25/19.
//  Copyright © 2019 c0nman. All rights reserved.
//

import SpriteKit
import CoreMotion

struct CollisionBitMask_bounce {
    static let Player: UInt32 = 0x00
    static let Checkpoint: UInt32 = 0x01
}

class GameScene_bounce: SKScene, SKPhysicsContactDelegate {
    
    weak var gameVC: GameViewController2?
    
    var started = false
    var isGameOver = false
    var isGamePaused = false
    var pauseButton = SKSpriteNode()
    var pauseButtonBlurr = SKSpriteNode()
    
    var scoreLabel1 = SKSpriteNode(imageNamed: "num0")
    var scoreLabel2 = SKSpriteNode(imageNamed: "num0")
    var scoreLabel3 = SKSpriteNode(imageNamed: "num0")
    var blurr1 = SKSpriteNode(imageNamed: "BlueNum0")
    var blurr2 = SKSpriteNode(imageNamed: "BlueNum0")
    var blurr3 = SKSpriteNode(imageNamed: "BlueNum0")
    
    let numAtlas = SKTextureAtlas(named: "NumAtlas")
    
    var ones = 0
    var tens = 0
    var hundreds = 0
    var score = 0 {
        didSet {
            player.setScale(CGFloat(scaleNumber))
            ones += 1
            if score % 100 == 0 {
                ones = 0
                tens = 0
                hundreds += 1
                scoreLabel2.texture = SKTexture(imageNamed: "num\(tens)")
                blurr2.texture = numAtlas.textureNamed("BlueNum\(tens)")
                scoreLabel1.texture = SKTexture(imageNamed: "num\(hundreds)")
                blurr1.texture = numAtlas.textureNamed("BlueNum\(hundreds)")
                
            }
            
            if score % 10 == 0 && score % 100 != 0 {
                ones = 0
                tens += 1
                scoreLabel2.texture = SKTexture(imageNamed: "num\(tens)")
                blurr2.texture = numAtlas.textureNamed("BlueNum\(tens)")
                
                
            }
            scoreLabel3.texture = SKTexture(imageNamed: "num\(ones)")
            blurr3.texture = numAtlas.textureNamed("BlueNum\(ones)")
            
            if score >= 999 {
                scoreLabel1.texture = SKTexture(imageNamed: "num9")
                blurr1.texture = numAtlas.textureNamed("BlueNum9")
                
                scoreLabel2.texture = SKTexture(imageNamed: "num9")
                blurr2.texture = numAtlas.textureNamed("BlueNum9")
                
                scoreLabel3.texture = SKTexture(imageNamed: "num9")
                blurr3.texture = numAtlas.textureNamed("BlueNum9")
            }
            
        
            switch score {
            case _ where score > 25 && score <= 50:
                moveNumber = 9
            case _ where score > 50 && score <= 75:
                moveNumber = 8
            case _ where score > 75 && score <= 100:
                moveNumber = 7
            case _ where score > 100 && score <= 125:
                moveNumber = 6
            case _ where score > 125 && score <= 175:
                moveNumber = 5
            case _ where score > 175 && score <= 250:
                moveNumber = 4
            case _ where score > 250 && score <= 450:
                moveNumber = 3
            case _ where score > 450 && score <= 650:
                moveNumber = 2
            case _ where score > 650:
                moveNumber = 1
            default:
                print("moveNumber is false")
            }
        }
    }
    
    var player = SKSpriteNode()
    var playerBlurr = SKSpriteNode()
    var xMotion: CGFloat = 0
    let motionManager = CMMotionManager()
    let cam = SKCameraNode()
    var checkpointY = CGFloat(0)
    var gameOverY = CGFloat(0)
    var scaleNumber = 1.5
    var moveNumber = 1
    var speedNum = CGFloat(250)
    
    override func didMove(to view: SKView) {
        
        numAtlas.preload {
        }
        self.physicsWorld.contactDelegate = self
        self.camera = cam
        cam.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(cam)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_bounce.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addPauseButton()
        addBackButton()
        addScoreLabels()
        addPlayer()
        setupCheckpoints()
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xMotion = CGFloat(acceleration.x) * (self.size.width * 0.04)
                
            }
        }
    }
    
    override func didSimulatePhysics() {
        if isGamePaused == false && isGameOver == false {
            player.position.x += xMotion
            
            if player.position.x < 0 {
                player.position = CGPoint(x: 0, y: player.position.y)
            } else if player.position.x > self.size.width {
                player.position = CGPoint(x: self.size.width, y: player.position.y)
            }
        }
        
    }
    override func update(_ currentTime: TimeInterval) {
    
        if player.position.y < gameOverY && isGameOver == false {
            isGameOver = true
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.isDynamic = false
            let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
            let actionBack = SKAction.wait(forDuration: 2.0)
            
            self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                self.gameOver()
            })
        }
        
        enumerateChildNodes(withName: "CHECKPOINT") { (node, error) in
            if node.position.y < self.player.position.y - 500 {
                node.removeFromParent()
                self.score += 1
                self.addCheckpoint()
            }
        }
    }
    
    
    override func didFinishUpdate() {
                cam.position.y = player.position.y + 250
    }
    
    @objc func pauseGame() {
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButton")
        pauseButtonBlurr.texture = SKTexture(imageNamed: "GreenPlayButtonBlurr")
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    func addPauseButton() {
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "PauseButton"))
        pauseButtonBlurr = SKSpriteNode(imageNamed: "GreenPauseButtonBlurr")
        pauseButton.name = "PauseButton"
        pauseButton.position = CGPoint(x: 325 - pauseButtonBlurr.size.width/2 - 25, y: 667 - pauseButtonBlurr.size.height/2 - 25)
        pauseButton.zPosition = 6
        cam.addChild(pauseButton)
        pauseButton.addChild(pauseButtonBlurr)
        pauseButtonBlurr.zPosition = -1
        
        
        
    }
    
    func addBackButton() {
        let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        //backButton.size = CGSize(width: 32.3, height: 75)
        backButton.zPosition = 6
        cam.addChild(backButton)
        
        let backButtonBlurr = SKSpriteNode(imageNamed: "RedBackButtonBlurr")
        //ZbackButtonBlurr.size = CGSize(width: 67.2, height: 115.8)
        backButton.addChild(backButtonBlurr)
        backButtonBlurr.zPosition = -1
        
        backButton.position = CGPoint(x: -325 + backButtonBlurr.size.width/2 + 25, y: 667 - backButtonBlurr.size.height/2 - 25)
        
    }
    
    func addScoreLabels() {
        scoreLabel1.zPosition = 3
        scoreLabel1.position = CGPoint(x: -scoreLabel1.size.width - 20, y: 667 - scoreLabel1.size.height/2 - 40)
        scoreLabel2.zPosition = 3
        scoreLabel2.position = CGPoint(x: 0, y: 667 - scoreLabel2.size.height/2 - 40)
        scoreLabel3.zPosition = 3
        scoreLabel3.position = CGPoint(x: scoreLabel3.size.width + 20, y: 667 - scoreLabel3.size.height/2 - 40)
        
        cam.addChild(scoreLabel1)
        cam.addChild(scoreLabel2)
        cam.addChild(scoreLabel3)
        
        
        
        scoreLabel1.addChild(blurr1)
        scoreLabel2.addChild(blurr2)
        scoreLabel3.addChild(blurr3)
        
        blurr1.zPosition = -1
        blurr2.zPosition = -1
        blurr3.zPosition = -1
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "Disc")
        player.setScale(CGFloat(scaleNumber))
        player.position = CGPoint(x: self.size.width/2, y: 0)
        player.name = "PLAYER"
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = CollisionBitMask_bounce.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = CollisionBitMask_bounce.Checkpoint
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.mass = 0.13635388016700745
        self.addChild(player)
        playerBlurr = SKSpriteNode(imageNamed: "GreenDiscBlurr")
        player.addChild(playerBlurr)
        playerBlurr.zPosition = -1
    }
    
    
    func addCheckpoint() {
        let checkpoint = SKSpriteNode(imageNamed: "Disc")
        checkpoint.setScale(CGFloat(scaleNumber))
        let randomX = Int(arc4random_uniform(UInt32(750)))

        checkpoint.position = CGPoint(x: CGFloat(randomX), y: checkpointY + 320)
        checkpoint.name = "CHECKPOINT"
        checkpoint.physicsBody = SKPhysicsBody(circleOfRadius: checkpoint.size.width/2)
        checkpoint.physicsBody?.categoryBitMask = CollisionBitMask_bounce.Checkpoint
        checkpoint.physicsBody?.collisionBitMask = 0
        checkpoint.physicsBody?.isDynamic = true
        checkpoint.physicsBody?.affectedByGravity = false
        self.addChild(checkpoint)
        
        
        
        let randomMoveNumber = arc4random_uniform(UInt32(moveNumber))
        let leftOrRight = arc4random_uniform(UInt32(2))
        var firstX = CGFloat()
        var secondX = CGFloat()
        var initialXTime = CGFloat()
        if leftOrRight == 0 {
            initialXTime = checkpoint.position.x/speedNum
            firstX = 0
            secondX = 750
        } else {
            initialXTime = (750 - checkpoint.position.x)/speedNum
            firstX = 750
            secondX = 0
        }
        
        if randomMoveNumber == 0 {
            let checkpointBlurr = SKSpriteNode(imageNamed: "RedDiscBlurr")
            checkpoint.addChild(checkpointBlurr)
            checkpointBlurr.zPosition = -1
            
            
            
            let firstAction = SKAction.moveTo(x: firstX, duration: TimeInterval(initialXTime))
            let secondAction = SKAction.moveTo(x: secondX, duration: TimeInterval(750/speedNum))
            let thirdAction = SKAction.moveTo(x: firstX, duration: TimeInterval(750/speedNum))
            let actionSequence = SKAction.sequence([secondAction, thirdAction])
            let foreverSequence = SKAction.repeatForever(actionSequence)
            let completeAction = SKAction.sequence([firstAction, foreverSequence])
            checkpoint.run(completeAction)
        } else {
            let checkpointBlurr = SKSpriteNode(imageNamed: "BlueDiscBlurr")
            checkpoint.addChild(checkpointBlurr)
            checkpointBlurr.zPosition = -1
        }
        
        if scaleNumber > 0.5 {
            scaleNumber -= 0.002
        }
        if speedNum < 500 {
            speedNum += 0.3
        }
        checkpointY += 250
    }
    
    func setupCheckpoints() {
        for _ in 0...10 {
            addCheckpoint()
        }
    }
    
    func gameOver() {
        
        UserDefaults.standard.set(score, forKey: "RecentScore_bounce")
        if score > UserDefaults.standard.integer(forKey: "HighScore_bounce") {
            UserDefaults.standard.set(score, forKey: "HighScore_bounce")
        }
        
        let scene = MenuScene(fileNamed: "MenuScene")
        scene?.scaleMode = .aspectFit
        scene?.gameVC = self.gameVC
        scene?.gameName = "bounce"
        
        self.view?.presentScene(scene!, transition: SKTransition.push(with: SKTransitionDirection.down, duration: 0.25))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "PLAYER" || contact.bodyA.node?.name == "CHECKPOINT" {
            score += 1
            addCheckpoint()
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 172))
        }
        if contact.bodyA.node?.name == "CHECKPOINT" {
            gameOverY = (contact.bodyA.node?.position.y)! - 300
            contact.bodyA.node?.removeFromParent()
        } else {
            gameOverY = (contact.bodyB.node?.position.y)! - 300
            contact.bodyB.node?.removeFromParent()
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !started && !isPaused {
            player.physicsBody?.isDynamic = true
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 172))
            player.physicsBody?.affectedByGravity = true
            started = true
        }
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                let menuScene = MenuScene(fileNamed: "MenuScene")
                menuScene?.scaleMode = .aspectFit
                menuScene?.gameName = "bounce"
                menuScene?.gameVC = gameVC
                
                self.view?.presentScene(menuScene!, transition: SKTransition.push(with: SKTransitionDirection.down, duration: 0.25))
            }
            
            if atPoint(location).name == "PauseButton" {
                if isGamePaused == false {
                    pauseGame()
                } else {
                    isGamePaused = false
                    self.isPaused = false
                    pauseButton.texture = SKTexture(imageNamed: "PauseButton")
                    pauseButtonBlurr.texture = SKTexture(imageNamed: "GreenPauseButtonBlurr")
                    self.speed = 1.0
                    self.physicsWorld.speed = 1.0
                }
            }
            
        }
    }
}
