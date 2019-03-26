//
//  GameScene_match.swift
//  MiniGames!
//
//  Created by Pete Connor on 3/21/19.
//  Copyright © 2019 c0nman. All rights reserved.
//

import Foundation
import SpriteKit

struct CollisionBitMask_match {
    static let Player: UInt32 = 0x00
    static let Checkpoint: UInt32 = 0x01
}

class GameScene_match: SKScene, SKPhysicsContactDelegate {
    
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
    
    var player = SKSpriteNode()
    var playerblur = SKSpriteNode()
    var removalList = [SKSpriteNode]()
    
    
    override func didMove(to view: SKView) {
        
        numAtlas.preload {
        }
        self.physicsWorld.contactDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_match.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addPauseButton()
        addBackButton()
        addScoreLabels()
        addPlayer()
        changePlayer()
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
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "Disc")
        player.setScale(2)
        player.position = CGPoint(x: self.size.width/2, y: 300)
        player.name = "Green"
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = CollisionBitMask_match.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = CollisionBitMask_match.Checkpoint
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        
        self.addChild(player)
        
        let randomNum = arc4random_uniform(3)
        
        switch randomNum {
        case 0:
            playerblur = SKSpriteNode(imageNamed: "GreenDiscblur")
            playerblur.name = "Green"
            player.addChild(playerblur)
            playerblur.zPosition = -1
        case 1:
            playerblur = SKSpriteNode(imageNamed: "RedDiscblur")
            playerblur.name = "Red"
            player.addChild(playerblur)
            playerblur.zPosition = -1
        case 2:
            playerblur = SKSpriteNode(imageNamed: "BlueDiscblur")
            playerblur.name = "Blue"
            player.addChild(playerblur)
            playerblur.zPosition = -1
        default:
            break
        
        }
    
    }
    
    func changePlayer() {
        let randomNum = arc4random_uniform(3)
        
        switch randomNum {
        case 0:
            playerblur.texture = SKTexture(imageNamed: "GreenDiscblur")
            player.name = "Green"
        case 1:
            playerblur.texture = SKTexture(imageNamed: "RedDiscblur")
            player.name = "Red"
        case 2:
            playerblur.texture = SKTexture(imageNamed: "BlueDiscblur")
            player.name = "Blue"
        default:
            break
        }
    }
    
    
    func addCheckpoints() {
        var checkList = ["Green", "Red", "Blue"]
        var checkNum = Int(arc4random_uniform(3))
        
        let checkpoint1 = SKSpriteNode(imageNamed: "Disc")
        checkpoint1.setScale(2)
        checkpoint1.position = CGPoint(x: 187.5 - checkpoint1.size.width/2, y: self.size.height + checkpoint1.size.height)
        checkpoint1.name = "\(checkList[checkNum])"
        checkpoint1.physicsBody = SKPhysicsBody(circleOfRadius: checkpoint1.size.width/2)
        checkpoint1.physicsBody?.categoryBitMask = CollisionBitMask_match.Checkpoint
        checkpoint1.physicsBody?.collisionBitMask = 0
        checkpoint1.physicsBody?.contactTestBitMask = CollisionBitMask_match.Player
        checkpoint1.physicsBody?.isDynamic = true
        checkpoint1.physicsBody?.affectedByGravity = false
        self.addChild(checkpoint1)
        let checkpoint1blur = SKSpriteNode(imageNamed: "\(checkList[checkNum])" + "Discblur")
        checkpoint1blur.zPosition = -1
        checkpoint1.addChild(checkpoint1blur)
        addMovement(checkpoint: checkpoint1)
        
        checkList.remove(at: checkNum)
        checkNum = Int(arc4random_uniform(2))
        
        let checkpoint2 = SKSpriteNode(imageNamed: "Disc")
        checkpoint2.setScale(2)
        checkpoint2.position = CGPoint(x: self.size.width/2, y: self.size.height + checkpoint2.size.height)
        checkpoint2.name = "\(checkList[checkNum])"
        checkpoint2.physicsBody = SKPhysicsBody(circleOfRadius: checkpoint2.size.width/2)
        checkpoint2.physicsBody?.categoryBitMask = CollisionBitMask_match.Checkpoint
        checkpoint2.physicsBody?.collisionBitMask = 0
        checkpoint2.physicsBody?.contactTestBitMask = CollisionBitMask_match.Player
        checkpoint2.physicsBody?.isDynamic = true
        checkpoint2.physicsBody?.affectedByGravity = false
        self.addChild(checkpoint2)
        let checkpoint2blur = SKSpriteNode(imageNamed: "\(checkList[checkNum])" + "Discblur")
        checkpoint2blur.zPosition = -1
        checkpoint2.addChild(checkpoint2blur)
        addMovement(checkpoint: checkpoint2)
        
        checkList.remove(at: checkNum)
        
        let checkpoint3 = SKSpriteNode(imageNamed: "Disc")
        checkpoint3.setScale(2)
        checkpoint3.position = CGPoint(x: 562.5 + checkpoint3.size.width/2, y: self.size.height + checkpoint3.size.height)
        checkpoint3.name = "\(checkList[0])"
        checkpoint3.physicsBody = SKPhysicsBody(circleOfRadius: checkpoint3.size.width/2)
        checkpoint3.physicsBody?.categoryBitMask = CollisionBitMask_match.Checkpoint
        checkpoint3.physicsBody?.collisionBitMask = 0
        checkpoint3.physicsBody?.contactTestBitMask = CollisionBitMask_match.Player
        checkpoint3.physicsBody?.isDynamic = true
        checkpoint3.physicsBody?.affectedByGravity = false
        self.addChild(checkpoint3)
        let checkpoint3blur = SKSpriteNode(imageNamed: "\(checkList[0])" + "Discblur")
        checkpoint3blur.zPosition = -1
        checkpoint3.addChild(checkpoint3blur)
        addMovement(checkpoint: checkpoint3)
        
        removalList.append(checkpoint1)
        removalList.append(checkpoint2)
        removalList.append(checkpoint3)
    }
    
    func addMovement(checkpoint: SKSpriteNode) {
        var actionList = [SKAction]()
        
        actionList.append(SKAction.move(to: CGPoint(x: checkpoint.position.x, y: 0), duration: 3))
        actionList.append(SKAction.removeFromParent())
        
        checkpoint.run(SKAction.sequence(actionList))
    }
    
    var lastUpdate = TimeInterval()
    var lastYieldTimeInterval = TimeInterval()
    var timeCheck = 0
    var timeInterval = 1.5
    
    override func update(_ currentTime: TimeInterval) {
        //print(timeInterval)
        if isGamePaused == false {
            if timeCheck == 1 {
                lastUpdate = currentTime
                timeCheck = 0
            }
            let timeSinceLastUpdate = currentTime - lastUpdate
            lastUpdate = currentTime
            lastYieldTimeInterval += timeSinceLastUpdate
            if lastYieldTimeInterval > timeInterval {
                timeInterval *= 0.997
                lastYieldTimeInterval = 0
                if !isGameOver {
                    addCheckpoints()
                }
            }
        }
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
    
    func gameOver() {
        
        UserDefaults.standard.set(score, forKey: "RecentScore_match")
        if score > UserDefaults.standard.integer(forKey: "HighScore_match") {
            UserDefaults.standard.set(score, forKey: "HighScore_match")
        }
        
        let scene = MenuScene(fileNamed: "MenuScene")
        scene?.scaleMode = .aspectFit
        scene?.gameVC = self.gameVC
        scene?.gameName = "match"
        
        UIApplication.shared.isIdleTimerDisabled = false
        
        self.view?.presentScene(scene!, transition: SKTransition.push(with: SKTransitionDirection.down, duration: 0.25))
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
                menuScene?.gameName = "match"
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
            
            if touch.location(in: self).x <= 250 && atPoint(location).name != "PauseButton" {
                player.position.x = 187.5 - player.size.width/2
            } else if touch.location(in: self).x > 250 && touch.location(in: self).x < 500 && atPoint(location).name != "PauseButton" {
                player.position.x = self.size.width/2

            } else if touch.location(in: self).x >= 500 && atPoint(location).name != "PauseButton" {
                player.position.x = 562.5 + player.size.width/2
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == contact.bodyB.node?.name {
            score += 1
            changePlayer()
            removalList[0].removeFromParent()
            removalList.removeFirst()
            removalList[0].removeFromParent()
            removalList.removeFirst()
            removalList[0].removeFromParent()
            removalList.removeFirst()
        } else {
            
            isGameOver = true
            
            self.isUserInteractionEnabled = false
            
            for i in removalList {
                i.removeAllActions()
            }
            
            let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
            let actionBack = SKAction.wait(forDuration: 2.0)
            
            self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                self.gameOver()
            })
            /*removalList[0].removeFromParent()
            removalList.removeFirst()
            removalList[0].removeFromParent()
            removalList.removeFirst()
            removalList[0].removeFromParent()
            removalList.removeFirst()*/
        }
        
    }
    
}



