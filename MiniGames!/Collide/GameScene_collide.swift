//
//  GameScene.swift
//  Collide
//
//  Created by Pete Connor on 3/27/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import SpriteKit

struct CollisionBitMask_collide {
    static let Player: UInt32 = 0x00
    static let Checkpoint: UInt32 = 0x01
}

class GameScene_collide: SKScene, SKPhysicsContactDelegate {
    
    weak var gameVC: GameViewController2?
    
    var started = false
    var touching = false
    var isGameOver = false
    var isGamePaused = false
    var pauseButton = SKSpriteNode()
    var pauseButtonBlurr = SKSpriteNode()
    var tapToStart = SKSpriteNode()

    
    var scoreLabel1 = SKSpriteNode(imageNamed: "num0")
    var scoreLabel2 = SKSpriteNode(imageNamed: "num0")
    var scoreLabel3 = SKSpriteNode(imageNamed: "num0")
    var blurr1 = SKSpriteNode(imageNamed: "GreenNum0")
    var blurr2 = SKSpriteNode(imageNamed: "GreenNum0")
    var blurr3 = SKSpriteNode(imageNamed: "GreenNum0")
    
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
                blurr2.texture = SKTexture(imageNamed: "GreenNum\(tens)")
                scoreLabel1.texture = SKTexture(imageNamed: "num\(hundreds)")
                blurr1.texture = SKTexture(imageNamed: "GreenNum\(hundreds)")
                
            }
            
            if score % 10 == 0 && score % 100 != 0 {
                ones = 0
                tens += 1
                scoreLabel2.texture = SKTexture(imageNamed: "num\(tens)")
                blurr2.texture = SKTexture(imageNamed: "GreenNum\(tens)")
                
                
            }
            scoreLabel3.texture = SKTexture(imageNamed: "num\(ones)")
            blurr3.texture = SKTexture(imageNamed: "GreenNum\(ones)")
            
            if score >= 999 {
                scoreLabel1.texture = SKTexture(imageNamed: "num9")
                blurr1.texture = SKTexture(imageNamed: "GreenNum9")
                
                scoreLabel2.texture = SKTexture(imageNamed: "num9")
                blurr2.texture = SKTexture(imageNamed: "GreenNum9")
                
                scoreLabel3.texture = SKTexture(imageNamed: "num9")
                blurr3.texture = SKTexture(imageNamed: "GreenNum9")
            }
        }
    }
    
    var player = SKSpriteNode()
    var playerBlurr = SKSpriteNode()
    var checkpoint = SKSpriteNode()
    
    var playerSpeed: CGFloat = 400
    var speedIncrease: CGFloat = 10
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self

        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_collide.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addBackButton()
        addPauseButton()
        addPlayer()
        addScoreLabels()
        addTapToStart()
    }
    
    func addTapToStart() {
        tapToStart = SKSpriteNode(imageNamed: "TapToStart")
        tapToStart.position = CGPoint(x: self.size.width/2, y: 200)
        addChild(tapToStart)
        tapToStart.zPosition = 3
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "Disc")
        player.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        player.name = "PLAYER"
        player.physicsBody?.isDynamic = true
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = CollisionBitMask_collide.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = CollisionBitMask_collide.Checkpoint
        player.physicsBody?.mass = 1.0
        addChild(player)
        
        playerBlurr = SKSpriteNode(imageNamed: "BlueDiscBlurr")
        player.addChild(playerBlurr)
        playerBlurr.zPosition = -1
    }
    
    func addCheckpoint() {
        checkpoint = SKSpriteNode(imageNamed: "Disc")
        //checkpoint.size = CGSize(width: 30, height: 30)
        placeCheckpoint()
        checkpoint.name = "CHECKPOINT"
        checkpoint.physicsBody?.isDynamic = true
        checkpoint.physicsBody = SKPhysicsBody(circleOfRadius: checkpoint.size.width/2)
        checkpoint.physicsBody?.categoryBitMask = CollisionBitMask_collide.Checkpoint
        checkpoint.physicsBody?.collisionBitMask = 0
        checkpoint.physicsBody?.mass = 1.0
        addChild(checkpoint)
        
        let checkpointBlurr = SKSpriteNode(imageNamed: "RedDiscBlurr")
        checkpoint.addChild(checkpointBlurr)
        checkpointBlurr.zPosition = -1
    }
    
    func placeCheckpoint() {
        
        var randomX = Int(arc4random_uniform(UInt32(650)) + 50)
        var randomY = Int(arc4random_uniform(UInt32(820)) + 300)
        
        
        // print("random x \(randomX) minus player position x\(player.position.x)")
        //print("random y \(randomY) minus \(player.position.y)")
        //print("diff \(abs(player.position.x - CGFloat(randomX)), abs(player.position.y - CGFloat(randomY)))")
        //print(abs(player.position.x - CGFloat(randomX)) < 200, abs(player.position.y) < 200)
        
        while abs(player.position.x - CGFloat(randomX)) < 15 || abs(player.position.y - CGFloat(randomY)) < 15 {
            randomX = Int(arc4random_uniform(UInt32(650)) + 50)
            randomY = Int(arc4random_uniform(UInt32(820)) + 300)
            //print("new random x \(randomX)")
            //print("new random y \(randomY)")
        }
        
        checkpoint.position = CGPoint(x: randomX, y: randomY)
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
    
    func movePlayer() {
        var vector = CGVector(dx: checkpoint.position.x - player.position.x, dy: checkpoint.position.y - player.position.y)
        let length = hypot(vector.dx, vector.dy)
        
        vector.dx *= playerSpeed / length
        vector.dy *= playerSpeed / length
        
        player.physicsBody?.applyImpulse(vector)
    }
    
    @objc func pauseGame() {
        //timeCheck = 1
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButton")
        pauseButtonBlurr.texture = SKTexture(imageNamed: "RedPlayButtonBlurr")
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    func gameOver() {
        
        UserDefaults.standard.set(score, forKey: "RecentScore_collide")
        if score > UserDefaults.standard.integer(forKey: "HighScore_collide") {
            UserDefaults.standard.set(score, forKey: "HighScore_collide")
        }
            let scene = MenuScene(fileNamed: "MenuScene")
            scene?.scaleMode = .aspectFit
            scene?.gameVC = self.gameVC
            scene?.gameName = "collide"
            
            self.view?.presentScene(scene!, transition: SKTransition.push(with: SKTransitionDirection.down, duration: 0.25))
    }
    
    func addBackButton() {
        let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        //backButton.size = CGSize(width: 32.3, height: 75)
        backButton.zPosition = 6
        addChild(backButton)
        
        let backButtonBlurr = SKSpriteNode(imageNamed: "BlueBackButtonBlurr")
        //ZbackButtonBlurr.size = CGSize(width: 67.2, height: 115.8)
        backButton.addChild(backButtonBlurr)
        backButtonBlurr.zPosition = -1
        
        backButton.position = CGPoint(x: 0 + backButtonBlurr.size.width/2 + 25, y: 1334 - backButtonBlurr.size.height/2 - 25)
        
    }
    
    func addPauseButton() {
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "PauseButton"))
        pauseButton.name = "PauseButton"
        //pauseButton.size.width = 42.7
        //pauseButton.size.height = 75
        
        pauseButton.zPosition = 6
        addChild(pauseButton)
        
        pauseButtonBlurr = SKSpriteNode(imageNamed: "RedPauseButtonBlurr")
        //pauseButtonBlurr.size = CGSize(width: 72.4, height: 104.7)
        pauseButton.addChild(pauseButtonBlurr)
        pauseButtonBlurr.zPosition = -1
        
        pauseButton.position = CGPoint(x: 750 - pauseButtonBlurr.size.width/2 - 25, y: 1334 - pauseButtonBlurr.size.height/2 - 25)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if started && atPoint(location).name != "BackButton" && atPoint(location).name != "PauseButton" && !isGameOver && !isGamePaused {
                if touching {
                    let greenAction = SKAction.run {
                        self.playerBlurr.texture = SKTexture(imageNamed: "GreenDiscBlurr")
                    }
                    
                    let waitAction = SKAction.wait(forDuration: 0.25)
                    
                    let blueAction = SKAction.run {
                        self.playerBlurr.texture = SKTexture(imageNamed: "BlueDiscBlurr")
                    }
                    
                    
                    player.run(SKAction.sequence([greenAction, waitAction, blueAction]))
                    
                    score += 1
                    touching = false
                    player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    playerSpeed += speedIncrease
                    speedIncrease *= 0.98
                    placeCheckpoint()
                    movePlayer()
                } else {
                    isGameOver = true
                    player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    self.isUserInteractionEnabled = false
                    
                    let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
                    let actionBack = SKAction.wait(forDuration: 2.0)
                    
                    self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                        self.gameOver()
                    })
                }
            }
            
            if atPoint(location).name == "BackButton" {
                let menuScene = MenuScene(fileNamed: "MenuScene")
                menuScene?.scaleMode = .aspectFit
                menuScene?.gameName = "collide"
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
                    pauseButtonBlurr.texture = SKTexture(imageNamed: "RedPauseButtonBlurr")
                    self.speed = 1.0
                    self.physicsWorld.speed = 1.0
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !started {
            started = true
            tapToStart.removeFromParent()
            addCheckpoint()
            movePlayer()
            //scoreLabel.text = "0"
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        //print(touching)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
            if contact.bodyA.node?.name == "PLAYER" || contact.bodyA.node?.name == "CHECKPOINT" {
                touching = true
            }
    
            
            /*player.isUserInteractionEnabled = false
            
            let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
            let actionBack = SKAction.wait(forDuration: 2.0)
            
            self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                self.gameOver()
            })*/
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "PLAYER" || contact.bodyA.node?.name == "CHECKPOINT" {

            touching = false
            isGameOver = true
            
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.isUserInteractionEnabled = false
            
            let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
            let actionBack = SKAction.wait(forDuration: 2.0)
            
            self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                self.gameOver()
            })
        }
    }
    
}
