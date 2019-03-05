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
    static let Obstacle: UInt32 = 0x01
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
        }
    }
    
    var player = SKSpriteNode()
    var checkpoint = SKSpriteNode()
    var xMotion: CGFloat = 0
    let motionManager = CMMotionManager()
    let cam = SKCameraNode()
    

    override func didMove(to view: SKView) {
        
        numAtlas.preload {
        }
        self.physicsWorld.contactDelegate = self
        //self.camera = cam
        //cam.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        //self.addChild(cam)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_bounce.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addPauseButton()
        addBackButton()
        addScoreLabels()
        addPlayer()
        addPlayerBlurr()
        addCheckpoint()
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xMotion = CGFloat(acceleration.x) * (self.size.width * 0.04)
            }
        }
    }
    
    override func didSimulatePhysics() {
        if isGamePaused == false {
            player.position.x += xMotion
            
            if player.position.x < 0 {
                player.position = CGPoint(x: 0, y: player.position.y)
            } else if player.position.x > self.size.width {
                player.position = CGPoint(x: self.size.width, y: player.position.y)
            }
        }
        
    }
    
    
    override func didFinishUpdate() {
                cam.position.y = player.position.y
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
        player.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        player.name = "PLAYER"
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = CollisionBitMask_collide.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = CollisionBitMask_collide.Checkpoint
        player.physicsBody?.isDynamic = true

        self.addChild(player)
    }
    
    func addPlayerBlurr() {
        let playerBlurr = SKSpriteNode(imageNamed: "GreenDiscBlurr")
        player.addChild(playerBlurr)
        playerBlurr.zPosition = -1
    }
    
    func addCheckpoint() {
        checkpoint = SKSpriteNode(imageNamed: "Disc")
        checkpoint.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        checkpoint.name = "CHECKPOINT"
        checkpoint.physicsBody = SKPhysicsBody(circleOfRadius: checkpoint.size.width/2)
        checkpoint.physicsBody?.categoryBitMask = CollisionBitMask_collide.Checkpoint
        checkpoint.physicsBody?.collisionBitMask = 0
        checkpoint.physicsBody?.isDynamic = true

        self.addChild(checkpoint)
        
        let checkpointBlurr = SKSpriteNode(imageNamed: "RedDiscBlurr")
        checkpoint.addChild(checkpointBlurr)
        checkpointBlurr.zPosition = -1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "PLAYER" || contact.bodyA.node?.name == "CHECKPOINT" {
            print(true)
            print(true)
            print(true)
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !started && !isPaused {
            player.physicsBody?.isDynamic = true
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))
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
