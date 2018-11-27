//
//  GameScene.swift
//  SpaceShooter
//
//  Created by Pete Connor on 3/5/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene_ss: SKScene, SKPhysicsContactDelegate {
    
    var pauseButton = SKSpriteNode()

    var isGamePaused = false
    
    weak var gameVC: GameViewController2?
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var backButton: SKSpriteNode!
    
    //var gameTimer: Timer!
    
    
    var possibleAliens = ["alien", "alien2", "alien3"]
    
    let alienCategory: UInt32 = 0x1 << 1
    let photonTorpedoCategory: UInt32 = 0x1 << 0
    
    var timeInterval = 0.8
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var livesArray: [SKSpriteNode]!
    
    override func didMove(to view: SKView) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_ss.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addBackButton()
        addPauseButton()
        
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.particlePositionRange = CGVector(dx: frame.size.width, dy: frame.size.height)

        starfield.position = CGPoint(x: frame.midX, y: self.size.height)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        let safeArea = view.safeAreaInsets.bottom
        player.position = CGPoint(x: self.size.width/2, y: 0 + player.size.height + 60 + safeArea)
        player.size.width = self.size.width * 0.1
        player.size.height = player.size.width * 1.43
        addChild(player)
        player.zPosition = 1
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        /*let thruster = SKEmitterNode(fileNamed: "Thruster")!
        if UIDevice.current.userInterfaceIdiom == .pad {
            thruster.particlePositionRange.dx = 20
            thruster.particleBirthRate = 400
            thruster.particleSpeed = 30
            thruster.particleLifetime = 1
            thruster.particleLifetimeRange = 1*/
        //}
        
        //thruster.position.y = player.position.y - player.size.height/2
        //thruster.position.x = player.position.x
        player.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        //thruster.targetNode = player
        //player.addChild(thruster)
        
        scoreLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: backButton.position.x + backButton.size.width, y: backButton.position.y - backButton.size.height/3)
        scoreLabel.horizontalAlignmentMode = .left
        //scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        addChild(scoreLabel)
        
        addLives()
        
        /*if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.3
        }*/
        
       // gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * (self.size.width * 0.04)
            }
        }
        
        }
    
    func addLives() {
        livesArray = [SKSpriteNode]()
        
        for life in 1...3 {
            let lifeNode = SKSpriteNode(imageNamed: "shuttle")
            lifeNode.setScale(0.6)
            lifeNode.position = CGPoint(x: self.size.width - CGFloat(4 - life) * lifeNode.size.width - pauseButton.size.width, y: self.size.height - 40)
            self.addChild(lifeNode)
            livesArray.append(lifeNode)
        }
    }
    
        
    @objc func addAlien() {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien =  SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: Int(0 + alien.size.width/2), highestValue: Int(self.size.width - alien.size.width/2))
        //switch highest to maxX???????????????
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.size.width = self.size.width * 0.08
        alien.size.height = alien.size.width * 0.5
        alien.position = CGPoint(x: position, y: self.size.height + alien.size.height)
        alien.physicsBody = SKPhysicsBody(circleOfRadius: alien.size.width/2)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        addChild(alien)
        
        var actionArray = [SKAction]()
        
        let animationDuration = 6.0
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: 0 - alien.size.height), duration: TimeInterval(animationDuration)))
        
        actionArray.append(SKAction.run {
            //self.run(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
            if self.livesArray.count > 0 {
                let lifeNode = self.livesArray.first
                lifeNode!.removeFromParent()
                self.livesArray.removeFirst()
                
                if self.livesArray.count == 0 {
                    self.player.removeFromParent()
                    let explosion = SKEmitterNode(fileNamed: "Explosion")!
                    explosion.position = self.player.position
                    self.addChild(explosion)
                    self.isUserInteractionEnabled = false
                    let wait = SKAction.wait(forDuration: 3.0)
                    self.run(wait, completion: {
                        self.gameOver()
                    })
                }
            }
        })
        
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
    }
    
    func fireTorpedo() {
        //self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        torpedoNode.setScale(0.5)
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(torpedoNode)
        
        let torpedoDuration = 0.3
        var actionArray = [SKAction]()

        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.size.height + torpedoNode.size.height), duration: torpedoDuration))
        
        actionArray.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                
                let menuScene = MenuScene_ss(size: view!.bounds.size)
                menuScene.scaleMode = .aspectFill
                menuScene.gameVC = gameVC
                self.view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 1))
            }
        
        if isGamePaused == false && atPoint(location).name != "PauseButton" {
            fireTorpedo()
            }
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
        if atPoint(location).name == "PauseButton" {
            if isGamePaused == false {
                pauseGame()
            } else {
                isGamePaused = false
                self.isPaused = false
                pauseButton.texture = SKTexture(imageNamed: "PauseButtonWhite")
                //gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
                self.speed = 1.0
                self.physicsWorld.speed = 1.0
            }
            }
        }
        
    }
    
    @objc func pauseGame() {
        timeCheck = 1
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButtonWhite")
        //gameTimer.invalidate()
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
                torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func torpedoDidCollideWithAlien(torpedoNode: SKSpriteNode, alienNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        addChild(explosion)
        
        //self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        score += 1
        /*if timeInterval > 0.3 {
            timeInterval *= 0.99
        } else if timeInterval > 0.1 {
            timeInterval *= 0.999
        } else {
            timeInterval *= 0.9999
        }*/
        //gameTimer.invalidate()
        //gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
    }
    
    override func didSimulatePhysics() {
        if isGamePaused == false {
            player.position.x += xAcceleration
            
            if player.position.x < 0 {
                player.position = CGPoint(x: 0, y: player.position.y)
            } else if player.position.x > self.size.width {
                player.position = CGPoint(x: self.size.width, y: player.position.y)
            }
        }
        
    }
    
    var lastUpdate = TimeInterval()
    var lastYieldTimeInterval = TimeInterval()
    var timeCheck = 0
    
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
                addAlien()
            }
        }
    }
    
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "RecentScore_ss")
        if score > UserDefaults.standard.integer(forKey: "HighScore_ss") {
            UserDefaults.standard.set(score, forKey: "HighScore_ss")
        }
        
        let menuScene = MenuScene_ss(size: view!.bounds.size)
        menuScene.scaleMode = .aspectFill
        menuScene.gameVC = gameVC
        view!.presentScene(menuScene)
    }
    
    func addBackButton() {
        backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        backButton.size.width = self.size.width/10
        backButton.size.height = backButton.size.width
        backButton.position = CGPoint(x: 0 + backButton.size.width/2, y: self.size.height - backButton.size.height/2 - 20)
        backButton.zPosition = 6
        
        
        addChild(backButton)
        backButton.color = .white
        backButton.colorBlendFactor = 1.0
    }
    
    func addPauseButton() {
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "PauseButtonWhite"))
        pauseButton.name = "PauseButton"
        pauseButton.size.width = self.size.width/10
        pauseButton.size.height = pauseButton.size.width
        pauseButton.position = CGPoint(x: self.size.width - pauseButton.size.width/2, y: self.size.height - pauseButton.size.height/2 - 20)
        pauseButton.zPosition = 6
        addChild(pauseButton)
    }
}
