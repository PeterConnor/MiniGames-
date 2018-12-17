//
//  GameScene.swift
//  PopALock
//
//  Created by Pete Connor on 3/27/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import SpriteKit

struct CollisionBitMask_pop {
    static let Player: UInt32 = 0x00
    static let Checkpoint: UInt32 = 0x01
}

class GameScene_pop: SKScene, SKPhysicsContactDelegate {
    
    weak var gameVC: GameViewController2?
    
    var started = false
    var touching = false
    var isGameOver = false
    var isGamePaused = false
    var pauseButton = SKSpriteNode()

    
    var scoreLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
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

        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_pop.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addBackButton()
        addPauseButton()
        addPlayer()
        addScoreLabel()
        
    
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "Disc")
        player.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        player.name = "PLAYER"
        player.physicsBody?.isDynamic = true
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = CollisionBitMask_pop.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = CollisionBitMask_pop.Checkpoint
        //print("player mass \(player.physicsBody?.mass)")
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
        checkpoint.physicsBody?.categoryBitMask = CollisionBitMask_pop.Checkpoint
        checkpoint.physicsBody?.collisionBitMask = 0
        checkpoint.physicsBody?.mass = 1.0
        addChild(checkpoint)
        
        let checkpointBlurr = SKSpriteNode(imageNamed: "RedDiscBlurr")
        checkpoint.addChild(checkpointBlurr)
        checkpointBlurr.zPosition = -1
    }
    
    func placeCheckpoint() {
        
        var randomX = Int(arc4random_uniform(UInt32(650)) + 50)
        var randomY = Int(arc4random_uniform(UInt32(1150)) + 50)
       // print("random x \(randomX) minus player position x\(player.position.x)")
        //print("random y \(randomY) minus \(player.position.y)")
        //print("diff \(abs(player.position.x - CGFloat(randomX)), abs(player.position.y - CGFloat(randomY)))")
        print(abs(player.position.x - CGFloat(randomX)) < 200, abs(player.position.y) < 200)
        
        while abs(player.position.x - CGFloat(randomX)) < 10 || abs(player.position.y - CGFloat(randomY)) < 10 {
            randomX = Int(arc4random_uniform(UInt32(650)) + 50)
            randomY = Int(arc4random_uniform(UInt32(1150)) + 50)
            //print("new random x \(randomX)")
            //print("new random y \(randomY)")
        }
        
        checkpoint.position = CGPoint(x: randomX, y: randomY)
    }
    
    func addScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
        scoreLabel.position = CGPoint(x: self.frame.midX, y: 1334 - scoreLabel.frame.size.height - 40)
        scoreLabel.fontColor = .white
        scoreLabel.zPosition = 3
        scoreLabel.text = "Tap to Start"
        
        self.addChild(scoreLabel)
    }
    
    func movePlayer() {
        var vector = CGVector(dx: checkpoint.position.x - player.position.x, dy: checkpoint.position.y - player.position.y)
        var length = hypot(vector.dx, vector.dy)
        
        vector.dx *= playerSpeed / length
        vector.dy *= playerSpeed / length
        
        player.physicsBody?.applyImpulse(vector)
    }
    
    @objc func pauseGame() {
        //timeCheck = 1
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButtonWhite")
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    func gameOver() {
        
        UserDefaults.standard.set(score, forKey: "RecentScore_pop")
        if score > UserDefaults.standard.integer(forKey: "HighScore_pop") {
            UserDefaults.standard.set(score, forKey: "HighScore_pop")
        }
        
        if let view = self.view as SKView? {
            let scene = MenuScene_pop(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            scene.gameVC = self.gameVC
            view.presentScene(scene)
        }
    }
    
    func addBackButton() {
        let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        backButton.size.width = frame.size.width/10
        backButton.size.height = backButton.size.width
        backButton.position = CGPoint(x: frame.minX + backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 40)
        backButton.zPosition = 6
        addChild(backButton)
    }
    
    func addPauseButton() {
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "PauseButtonWhite"))
        pauseButton.name = "PauseButton"
        pauseButton.size.width = frame.size.width/10
        pauseButton.size.height = pauseButton.size.width
        pauseButton.position = CGPoint(x: frame.maxX - pauseButton.size.width/2, y: frame.maxY - pauseButton.size.height/2 - 40)
        pauseButton.zPosition = 6
        addChild(pauseButton)
        
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
                    print(playerSpeed)
                    placeCheckpoint()
                    movePlayer()
                } else {
                    isGameOver = true
                    gameOver()
                }
            }
            
            if atPoint(location).name == "BackButton" {
                let menuScene = MenuScene_pop(size: view!.bounds.size)
                menuScene.scaleMode = .aspectFill
                menuScene.gameVC = gameVC
                
                self.view?.presentScene(menuScene, transition: SKTransition.doorway(withDuration: 1))
            }
            
            if atPoint(location).name == "PauseButton" {
                if isGamePaused == false {
                    pauseGame()
                } else {
                    isGamePaused = false
                    self.isPaused = false
                    pauseButton.texture = SKTexture(imageNamed: "PauseButtonWhite")
                    self.speed = 1.0
                    self.physicsWorld.speed = 1.0
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !started {
            started = true
            addCheckpoint()
            movePlayer()
            scoreLabel.text = "0"
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
            gameOver()
        }
    }
    
}

/*
import SpriteKit
import GameplayKit

class GameScene_pop: SKScene {
    
    var isGamePaused = false
    
    var pauseButton = SKSpriteNode()
    
    weak var gameVC: GameViewController2?
    
    var lock = SKShapeNode()
    var needle = SKShapeNode()
    var path = UIBezierPath()
    var dot = SKShapeNode()
    
    let zeroAngle: CGFloat = 0.0
    
    var started: Bool = false
    var touches = false
    
    var clockWise = Bool()
    
    var level = 1
    var dots = 0
    
    var levelLabel = SKLabelNode()
    var currentScoreLabel = SKLabelNode()
    
    var needleSpeed: CGFloat = 200
    var needleIncrease: CGFloat = 10
    
    override func didMove(to view: SKView) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_pop.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        layoutGame()
    }
    
    func layoutGame() {
        
        addPauseButton()
        addBackButton()
        
        backgroundColor = .black
        path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 120, startAngle: zeroAngle, endAngle: zeroAngle + CGFloat(Double.pi * 2), clockwise: true)
        
        lock = SKShapeNode(path: path.cgPath)
        lock.strokeColor = SKColor.gray
        lock.lineWidth = 40.0
        self.addChild(lock)
        
        let lockImage = SKSpriteNode(imageNamed: "LockImage")
        lockImage.zPosition = 2
        lockImage.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        lockImage.size = CGSize(width: lock.frame.size.width-80, height: lock.frame.size.height-80)
        self.addChild(lockImage)
        
        needle = SKShapeNode(rectOf: CGSize(width: 40.0 - 7.0, height: 7.0), cornerRadius: 3.5)
        needle.fillColor = UIColor.red
        needle.strokeColor = UIColor.red
        needle.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 120.0)
        needle.zRotation = 3.14 / 2
        needle.zPosition = 2.0
        self.addChild(needle)
        
        levelLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
        levelLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + self.frame.height/3)
        levelLabel.fontColor = SKColor.white
        levelLabel.text = "Level: \(level)"
        
        levelLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
        levelLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + self.frame.height/3)
        levelLabel.fontColor = .white
        levelLabel.text = "Level: \(level)"
        
        currentScoreLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
        currentScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.maxY * 0.2)
        currentScoreLabel.fontColor = .white
        currentScoreLabel.zPosition = 3
        currentScoreLabel.text = "Tap!"
        
        self.addChild(levelLabel)
        self.addChild(currentScoreLabel)

        
        newDot()
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                
                let menuScene = MenuScene_pop(size: view!.bounds.size)
                menuScene.scaleMode = .aspectFill
                menuScene.gameVC = gameVC
                self.view?.presentScene(menuScene, transition: SKTransition.crossFade(withDuration: 1))
            }
            
        
        
        if !started && atPoint(location).name != "PauseButton" {
            currentScoreLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            currentScoreLabel.text = "\(level - dots)"
            runClockwise()
            started = true
            clockWise = true
        } else {
            if isGamePaused == false && atPoint(location).name != "PauseButton" {
            dotTouched()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
        if atPoint(location).name == "PauseButton" && started == true {
            if isGamePaused == false {
                self.speed = 0.0
                self.physicsWorld.speed = 0.0
                self.isPaused = true
                isGamePaused = true
                pauseButton.texture = SKTexture(imageNamed: "PlayButtonWhite")
            } else {
                self.isPaused = false
                isGamePaused = false
                pauseButton.texture = SKTexture(imageNamed: "PauseButtonWhite")
                self.speed = 1.0
                self.physicsWorld.speed = 1.0
                }
            }
        }
    }
    
    @objc func pauseGame() {
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButtonWhite")
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    func runClockwise() {
        let dx = needle.position.x - self.frame.width / 2
        let dy = needle.position.y - self.frame.height / 2
        
        let radian = atan2(dy, dx)
        
        path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 120, startAngle: radian, endAngle: radian + CGFloat(Double.pi * 2), clockwise: true)
        
        let run = SKAction.follow(path.cgPath, asOffset: false, orientToPath: true, speed: CGFloat(needleSpeed))
        needle.run(SKAction.repeatForever(run).reversed())
        
    }
    
    func runCounterClockwise() {
        let dx = needle.position.x - self.frame.width / 2
        let dy = needle.position.y - self.frame.height / 2
        
        let radian = atan2(dy, dx)
        
        path = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 120, startAngle: radian, endAngle: radian + CGFloat(Double.pi * 2), clockwise: true)
        
        let run = SKAction.follow(path.cgPath, asOffset: false, orientToPath: true, speed: CGFloat(needleSpeed))
        needle.run(SKAction.repeatForever(run))
        
    }
    
    func dotTouched() {
        if touches == true {
            touches = false
            dots += 1
            currentScoreLabel.text = "\(level - dots)"
            if dots >= level {
                started = false
                completed()
                return
            }
            dot.removeFromParent()
            newDot()
            if clockWise {
                runCounterClockwise()
                clockWise = false
            } else {
                runClockwise()
                clockWise = true
            }
        } else {
            started = false
            touches = false
            gameOver()
        }
    }
    
    func updateLabel() {
        currentScoreLabel.text = "\(level - dots)"
    }
    
    func newDot() {
        dot = SKShapeNode(circleOfRadius: 15.0)
        dot.fillColor = .white
        dot.strokeColor = .clear
        
        let dx = needle.position.x - self.frame.width / 2
        let dy = needle.position.y - self.frame.height / 2
        
        let radian = atan2(dy, dx)
        
        if clockWise {
            let tempAngle = CGFloat.random(min: radian + 1.0, max: radian + 2.5)
            let tempPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 120, startAngle: tempAngle, endAngle: tempAngle + CGFloat(Double.pi * 2), clockwise: true)
            dot.position = tempPath.currentPoint
        } else {
            let tempAngle = CGFloat.random(min: radian - 1.0, max: radian - 2.5)
            let tempPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width/2, y: self.frame.height/2), radius: 120, startAngle: tempAngle, endAngle: tempAngle + CGFloat(Double.pi * 2), clockwise: true)
            dot.position = tempPath.currentPoint
        }
        
        self.addChild(dot)
    }
    
    func completed() {
        isUserInteractionEnabled = false
        needle.removeFromParent()
        needleIncrease *= 0.98
        needleSpeed += needleIncrease
        currentScoreLabel.text = "Won!"
        let actionGreen = SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 0.25)
        let actionBack = SKAction.wait(forDuration: 0.5)
        
        self.scene?.run(SKAction.sequence([actionGreen, actionBack]), completion: { () -> Void in
            self.removeAllChildren()
            self.clockWise = false
            self.dots = 0
            self.level += 1
            self.layoutGame()
        })
        
        
    }
    
    func gameOver() {
        isUserInteractionEnabled = false
        needle.removeFromParent()
        currentScoreLabel.text = "Fail!"
        let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
        let actionBack = SKAction.wait(forDuration: 0.5)
        
        UserDefaults.standard.set(level - 1, forKey: "RecentScore_pop")
        if level - 1 > UserDefaults.standard.integer(forKey: "HighScore_pop") {
            UserDefaults.standard.set(level - 1, forKey: "HighScore_pop")
        }
        
        self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
            let menuScene = MenuScene_pop(size: self.view!.bounds.size)
            menuScene.scaleMode = .aspectFill
            menuScene.gameVC = self.gameVC
            self.view!.presentScene(menuScene)
            //self.removeAllChildren()
            //self.clockWise = false
            //self.dots = 0
            //self.layoutGame()
        })
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if started {
            if needle.intersects(dot) {
                touches = true
            } else {
                if touches == true {
                    if !needle.intersects(dot) {
                        started = false
                        touches = false
                        gameOver()
                    }
                }
            }
        }
    }
    
    func addBackButton() {
        let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        backButton.size.width = frame.size.width/10
        backButton.size.height = backButton.size.width
        backButton.position = CGPoint(x: frame.minX + backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 20)
        backButton.zPosition = 6
        
        
        addChild(backButton)
        backButton.color = .white
        backButton.colorBlendFactor = 1.0
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
    
    
    
}*/
