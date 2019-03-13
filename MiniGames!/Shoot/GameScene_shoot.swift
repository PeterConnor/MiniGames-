//
//  GameScene_shoot.swift
//  MiniGames!
//
//  Created by Pete Connor on 3/10/19.
//  Copyright © 2019 c0nman. All rights reserved.
//

import SpriteKit
import CoreMotion

struct CollisionBitMask_shoot {
    static let Player: UInt32 = 0x00
    static let Enemy: UInt32 = 0x01
    static let Shot: UInt32 = 0x02
}

class GameScene_shoot: SKScene, SKPhysicsContactDelegate {
    
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
    var xMotion: CGFloat = 0
    let motionManager = CMMotionManager()
    
    override func didMove(to view: SKView) {
        
        numAtlas.preload {
        }
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_shoot.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addPauseButton()
        addBackButton()
        addScoreLabels()
        addPlayer()
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xMotion = CGFloat(acceleration.x) * (self.size.width * 0.04)
            }
        }
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
        pauseButton.name = "PauseButton"
        //pauseButton.size.width = 42.7
        //pauseButton.size.height = 75
        
        pauseButton.zPosition = 6
        addChild(pauseButton)
        
        pauseButtonBlurr = SKSpriteNode(imageNamed: "GreenPauseButtonBlurr")
        //pauseButtonBlurr.size = CGSize(width: 72.4, height: 104.7)
        pauseButton.addChild(pauseButtonBlurr)
        pauseButtonBlurr.zPosition = -1
        
        pauseButton.position = CGPoint(x: 750 - pauseButtonBlurr.size.width/2 - 25, y: 1334 - pauseButtonBlurr.size.height/2 - 25)
        
    }
    
    func addBackButton() {
        let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        //backButton.size = CGSize(width: 32.3, height: 75)
        backButton.zPosition = 6
        addChild(backButton)
        
        let backButtonBlurr = SKSpriteNode(imageNamed: "RedBackButtonBlurr")
        //ZbackButtonBlurr.size = CGSize(width: 67.2, height: 115.8)
        backButton.addChild(backButtonBlurr)
        backButtonBlurr.zPosition = -1
        
        backButton.position = CGPoint(x: 0 + backButtonBlurr.size.width/2 + 25, y: 1334 - backButtonBlurr.size.height/2 - 25)
        
    }
    
    func gameOver() {
        
        UserDefaults.standard.set(score, forKey: "RecentScore_shoot")
        if score > UserDefaults.standard.integer(forKey: "HighScore_shoot") {
            UserDefaults.standard.set(score, forKey: "HighScore_shoot")
        }
        
        let scene = MenuScene(fileNamed: "MenuScene")
        scene?.scaleMode = .aspectFit
        scene?.gameVC = self.gameVC
        scene?.gameName = "shoot"
        
        self.view?.presentScene(scene!, transition: SKTransition.push(with: SKTransitionDirection.down, duration: 0.25))
    }
    
    func addScoreLabels() {
        scoreLabel1.zPosition = 3
        scoreLabel1.position = CGPoint(x: self.size.width/2 - scoreLabel1.size.width - 20, y: 1334 - scoreLabel1.size.height/2 - 40)
        scoreLabel2.zPosition = 3
        scoreLabel2.position = CGPoint(x: self.size.width/2, y: 1334 - scoreLabel2.size.height/2 - 40)
        scoreLabel3.zPosition = 3
        scoreLabel3.position = CGPoint(x: self.size.width/2 + scoreLabel3.size.width + 20, y: 1334 - scoreLabel3.size.height/2 - 40)
        
        addChild(scoreLabel1)
        addChild(scoreLabel2)
        addChild(scoreLabel3)
        
        
        
        scoreLabel1.addChild(blurr1)
        scoreLabel2.addChild(blurr2)
        scoreLabel3.addChild(blurr3)
        
        blurr1.zPosition = -1
        blurr2.zPosition = -1
        blurr3.zPosition = -1
    }
    
    func shoot() {
        let shot = SKSpriteNode(imageNamed: "Disc")
        shot.position = player.position
        shot.position.y += 5
        shot.setScale(0.3)
        shot.physicsBody = SKPhysicsBody(circleOfRadius: shot.size.width/2)
        shot.physicsBody?.isDynamic = true
        shot.physicsBody?.categoryBitMask = CollisionBitMask_shoot.Shot
        shot.physicsBody?.contactTestBitMask = CollisionBitMask_shoot.Enemy
        shot.physicsBody?.collisionBitMask = 0
        shot.physicsBody?.usesPreciseCollisionDetection = true
        addChild(shot)
        
        let shotBlurr = SKSpriteNode(imageNamed: "BlueDiscBlurr")
        shot.addChild(shotBlurr)
        shotBlurr.zPosition = -1
        
        let shotTime = 0.25
        var actionList = [SKAction]()
        
        actionList.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.size.height + shot.size.height), duration: shotTime))
        
        actionList.append(SKAction.removeFromParent())
        
        shot.run(SKAction.sequence(actionList))
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "Disc")
        player.position = CGPoint(x: self.size.width/2, y: 300)
        player.name = "PLAYER"
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = CollisionBitMask_shoot.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = CollisionBitMask_shoot.Enemy
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        
        self.addChild(player)
        let playerBlurr = SKSpriteNode(imageNamed: "GreenDiscBlurr")
        player.addChild(playerBlurr)
        playerBlurr.zPosition = -1
    }
    
    @objc func addEnemy() {
        let randomNum = arc4random_uniform(2)
        
        let enemy = SKSpriteNode(imageNamed: "Disc")
        if randomNum == 1 {
            let enemyBlurr = SKSpriteNode(imageNamed: "RedDiscBlurr")
            enemy.addChild(enemyBlurr)
            enemyBlurr.zPosition = -1
        } else {
            let enemyBlurr = SKSpriteNode(imageNamed: "RedDiscBlurr")
            enemy.addChild(enemyBlurr)
            enemyBlurr.zPosition = -1
        }
        
        let randomX = Int(arc4random_uniform(UInt32(750)))
        
       enemy.position = CGPoint(x: CGFloat(randomX), y: 1334 + player.size.height)
        
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width/2)
        enemy.physicsBody?.isDynamic = true
        
        enemy.physicsBody?.categoryBitMask = CollisionBitMask_shoot.Enemy
        enemy.physicsBody?.contactTestBitMask = CollisionBitMask_shoot.Shot
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        
        addMovement(obs: enemy)
    }
    
    func addMovement(obs: SKSpriteNode) {
        var actionList = [SKAction]()
        
        actionList.append(SKAction.move(to: CGPoint(x: obs.position.x, y: 0 - obs.size.height), duration: 6))
        actionList.append(SKAction.removeFromParent())
        
        obs.run(SKAction.sequence(actionList))
    }
    
    var lastUpdate = TimeInterval()
    var lastYieldTimeInterval = TimeInterval()
    var timeCheck = 0
    var timeInterval = 0.8
    
    override func update(_ currentTime: TimeInterval) {
        print(timeInterval)
        if isGamePaused == false {
            if timeCheck == 1 {
                lastUpdate = currentTime
                timeCheck = 0
            }
            var timeSinceLastUpdate = currentTime - lastUpdate
            lastUpdate = currentTime
            lastYieldTimeInterval += timeSinceLastUpdate
            if lastYieldTimeInterval > timeInterval {
                timeInterval *= 0.997
                lastYieldTimeInterval = 0
                addEnemy()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if started && !isPaused {
            //canMove = true - from evade
        }
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                let menuScene = MenuScene(fileNamed: "MenuScene")
                menuScene?.scaleMode = .aspectFit
                menuScene?.gameName = "shoot"
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
            
            if isGamePaused == false && atPoint(location).name != "PauseButton" {
                shoot()
            }
            
            
        }
    }
    
}

