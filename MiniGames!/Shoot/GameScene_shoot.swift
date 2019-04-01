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
    var pauseButtonblur = SKSpriteNode()
    
    var scoreLabel1 = SKSpriteNode(imageNamed: "num0")
    var scoreLabel2 = SKSpriteNode(imageNamed: "num0")
    var scoreLabel3 = SKSpriteNode(imageNamed: "num0")
    var blur1 = SKSpriteNode(imageNamed: "BlueNum0")
    var blur2 = SKSpriteNode(imageNamed: "BlueNum0")
    var blur3 = SKSpriteNode(imageNamed: "BlueNum0")
    
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
                blur2.texture = numAtlas.textureNamed("BlueNum\(tens)")
                scoreLabel1.texture = SKTexture(imageNamed: "num\(hundreds)")
                blur1.texture = numAtlas.textureNamed("BlueNum\(hundreds)")
                
            }
            
            if score % 10 == 0 && score % 100 != 0 {
                ones = 0
                tens += 1
                scoreLabel2.texture = SKTexture(imageNamed: "num\(tens)")
                blur2.texture = numAtlas.textureNamed("BlueNum\(tens)")
                
                
            }
            scoreLabel3.texture = SKTexture(imageNamed: "num\(ones)")
            blur3.texture = numAtlas.textureNamed("BlueNum\(ones)")
            
            if score >= 999 {
                scoreLabel1.texture = SKTexture(imageNamed: "num9")
                blur1.texture = numAtlas.textureNamed("BlueNum9")
                
                scoreLabel2.texture = SKTexture(imageNamed: "num9")
                blur2.texture = numAtlas.textureNamed("BlueNum9")
                
                scoreLabel3.texture = SKTexture(imageNamed: "num9")
                blur3.texture = numAtlas.textureNamed("BlueNum9")
            }
        }
    }
    
    var tapToStart = SKSpriteNode()
    var player = SKSpriteNode()
    var enemiesList = [SKSpriteNode]()
    var xMotion: CGFloat = 0
    let motionManager = CMMotionManager()
    var scaleValue: CGFloat = 1.0
    
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
        addBackground()
        addTapToStart()
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xMotion = CGFloat(acceleration.x) * 32
            }
        }
    }
    
    @objc func pauseGame() {
        timeCheck = 1
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButton")
        pauseButtonblur.texture = SKTexture(imageNamed: "GreenPlayButtonblur")
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
        
        pauseButtonblur = SKSpriteNode(imageNamed: "GreenPauseButtonblur")
        //pauseButtonblur.size = CGSize(width: 72.4, height: 104.7)
        pauseButton.addChild(pauseButtonblur)
        pauseButtonblur.zPosition = -1
        
        pauseButton.position = CGPoint(x: 750 - pauseButtonblur.size.width/2 - 25, y: 1334 - pauseButtonblur.size.height/2 - 25)
        
    }
    
    func addBackButton() {
        let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        //backButton.size = CGSize(width: 32.3, height: 75)
        backButton.zPosition = 6
        addChild(backButton)
        
        let backButtonblur = SKSpriteNode(imageNamed: "RedBackButtonblur")
        //ZbackButtonblur.size = CGSize(width: 67.2, height: 115.8)
        backButton.addChild(backButtonblur)
        backButtonblur.zPosition = -1
        
        backButton.position = CGPoint(x: 0 + backButtonblur.size.width/2 + 25, y: 1334 - backButtonblur.size.height/2 - 25)
        
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
        
        
        
        scoreLabel1.addChild(blur1)
        scoreLabel2.addChild(blur2)
        scoreLabel3.addChild(blur3)
        
        blur1.zPosition = -1
        blur2.zPosition = -1
        blur3.zPosition = -1
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "BackgroundWhite")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 1
        
        self.addChild(background)
        
    }
    
    func addTapToStart() {
        tapToStart = SKSpriteNode(imageNamed: "TapToStart")
        tapToStart.position = CGPoint(x: self.size.width/2, y: 175)
        addChild(tapToStart)
        tapToStart.zPosition = 3
    }
    
    func shoot() {
        let shot = SKSpriteNode(imageNamed: "Disc")
        shot.name = "SHOT"
        shot.position = player.position
        shot.position.y += 30
        shot.setScale(0.4)
        shot.physicsBody = SKPhysicsBody(circleOfRadius: shot.size.width/2)
        shot.physicsBody?.isDynamic = true
        shot.physicsBody?.categoryBitMask = CollisionBitMask_shoot.Shot
        shot.physicsBody?.contactTestBitMask = CollisionBitMask_shoot.Enemy
        shot.physicsBody?.collisionBitMask = 0
        shot.physicsBody?.usesPreciseCollisionDetection = true
        addChild(shot)
        
        let shotblur = SKSpriteNode(imageNamed: "BlueDiscblur")
        shot.addChild(shotblur)
        shotblur.zPosition = -1
        
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
        let playerblur = SKSpriteNode(imageNamed: "GreenDiscblur")
        player.addChild(playerblur)
        playerblur.zPosition = -1
    }
    
    @objc func addEnemy() {
        let randomNum = arc4random_uniform(2)
        
        let enemy = SKSpriteNode(imageNamed: "Disc")
        enemy.name = "ENEMY"
        if randomNum == 1 {
            let enemyblur = SKSpriteNode(imageNamed: "RedDiscblur")
            enemy.addChild(enemyblur)
            enemyblur.zPosition = -1
        } else {
            let enemyblur = SKSpriteNode(imageNamed: "RedDiscblur")
            enemy.addChild(enemyblur)
            enemyblur.zPosition = -1
        }
        
        let randomX = Int(arc4random_uniform(UInt32(750)))
        
       enemy.position = CGPoint(x: CGFloat(randomX), y: 1334 + player.size.height)
        
        enemy.setScale(scaleValue)
        if scaleValue > 0.5 {
            scaleValue -= 0.001
        }
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width/2)
        enemy.physicsBody?.isDynamic = true
        
        
        
        enemy.physicsBody?.categoryBitMask = CollisionBitMask_shoot.Enemy
        enemy.physicsBody?.contactTestBitMask = CollisionBitMask_shoot.Shot
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        enemiesList.append(enemy)
        
        addMovement(obs: enemy)
        //addSideMovement(enemy: enemy)
        
        
    }
    
    func addMovement(obs: SKSpriteNode) {
        var actionList = [SKAction]()
        
        actionList.append(SKAction.move(to: CGPoint(x: obs.position.x, y: 0 - obs.size.height), duration: 6))
        actionList.append(SKAction.run({
            self.isGameOver = true
            for i in self.enemiesList {
                i.removeAllActions()
            }
            
            self.isUserInteractionEnabled = false
            
            let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
            let actionBack = SKAction.wait(forDuration: 2.0)
            
            self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                self.gameOver()
            })
        }))
        obs.run(SKAction.sequence(actionList))
    }
    
    func addSideMovement(enemy: SKSpriteNode) {
        var doSide = Int()
        if score < 25 {
            doSide = 0
        } else if score < 50 {
            doSide = Int(arc4random_uniform(UInt32(6)))
        } else if score < 100 {
            doSide = Int(arc4random_uniform(UInt32(5)))
        } else if score < 150 {
            doSide = Int(arc4random_uniform(UInt32(4)))
        } else if score < 250 {
            doSide = Int(arc4random_uniform(UInt32(3)))
        }
        
        if doSide == 2 {
            let leftOrRight = arc4random_uniform(UInt32(2))
            var firstX = CGFloat()
            var secondX = CGFloat()
            var initialXTime = CGFloat()
            if leftOrRight == 0 {
                initialXTime = enemy.position.x/250
                firstX = 0
                secondX = 750
            } else {
                initialXTime = (750 - enemy.position.x)/250
                firstX = 750
                secondX = 0
            }
            
            let firstAction = SKAction.moveTo(x: firstX, duration: TimeInterval(initialXTime))
            let secondAction = SKAction.moveTo(x: secondX, duration: TimeInterval(750/250))
            let thirdAction = SKAction.moveTo(x: firstX, duration: TimeInterval(750/250))
            let actionSequence = SKAction.sequence([secondAction, thirdAction])
            let foreverSequence = SKAction.repeatForever(actionSequence)
            let completeAction = SKAction.sequence([firstAction, foreverSequence])
            enemy.run(completeAction)
        }
    }
    
    var lastUpdate = TimeInterval()
    var lastYieldTimeInterval = TimeInterval()
    var timeCheck = 0
    var timeInterval = 1.2
    var timeIntervalMultiplier = 0.990
    
    override func update(_ currentTime: TimeInterval) {
        if isGamePaused == false {
            if timeCheck == 1 {
                lastUpdate = currentTime
                timeCheck = 0
            }
            let timeSinceLastUpdate = currentTime - lastUpdate
            lastUpdate = currentTime
            lastYieldTimeInterval += timeSinceLastUpdate
            if lastYieldTimeInterval > timeInterval {
                timeInterval *= timeIntervalMultiplier
                lastYieldTimeInterval = 0
                if !isGameOver && started {
                    addEnemy()
                }
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ENEMY" || contact.bodyA.node?.name == "SHOT" {
            score += 1
            if score % 25 == 0 {
                if timeIntervalMultiplier < 0.998 {
                timeIntervalMultiplier += 0.001
                }
            }
            if contact.bodyA.node?.name == "ENEMY" {
                
                contact.bodyB.node?.removeFromParent()
                
                contact.bodyA.node?.removeAllActions()
    
                    let scaleAction = SKAction.scale(to: 0, duration: 0.25)
                    contact.bodyA.node?.run(scaleAction, completion: {
                        contact.bodyA.node?.removeFromParent()
                    })

            } else {
                contact.bodyA.node?.removeFromParent()
                
                contact.bodyB.node?.removeAllActions()
                
                let scaleAction = SKAction.scale(to: 0, duration: 0.25)
                contact.bodyB.node?.run(scaleAction, completion: {
                    contact.bodyB.node?.removeFromParent()
                })

            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

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
                    pauseButtonblur.texture = SKTexture(imageNamed: "GreenPauseButtonblur")
                    self.speed = 1.0
                    self.physicsWorld.speed = 1.0
                }
            }
            
            if isGamePaused == false && started == true && atPoint(location).name != "PauseButton" {
                shoot()
            }
            
            if !started && !isPaused {
                started = true
                tapToStart.removeFromParent()
            }
            
        }
    }
    
}

