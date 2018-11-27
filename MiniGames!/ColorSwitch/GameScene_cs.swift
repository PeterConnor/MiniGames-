//
//  GameScene.swift
//  ColorSwitch
//
//  Created by Pete Connor on 2/10/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//cs

import SpriteKit
import GameplayKit

enum PlayColors_cs {
    static let colors = [/*green*/ UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
                        /*blue*/ UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0),
                        /*red*/ UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
                        /*yellow*/ UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0)
                        ]
}

enum SwitchState_cs: Int {
    case green, blue, red, yellow
}

class GameScene_cs: SKScene {
    
    var isGamePaused = false
    
    var pauseButton = SKSpriteNode()
    
    weak var gameVC: GameViewController2?
    
    var ball: SKSpriteNode!
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState_cs.green
    var currentColorIndex: Int?
    
    let scoreLabel = SKLabelNode(text: "0")
    var score = 0
    var scoreCheck = 0
    var switchSpeed = 1.5
    var switchIncrease = 0.2
    
    override func didMove(to view: SKView) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_ss.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        layoutScene()
        setupPhysics()
        turnWheel()
        addBackButton()
        addPauseButton()
        }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        let safeArea = view?.safeAreaInsets.bottom ?? 0
        physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: frame.minX, y: frame.minY + 50 + safeArea, width: frame.size.width, height: frame.size.height))
        physicsBody?.categoryBitMask = PhysicsCategories_cs.edgeCategory
    }
    
    func layoutScene() {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        colorSwitch.size = CGSize(width: frame.size.width/3, height: frame.size.width/3)
        colorSwitch.position = CGPoint(x: frame.midX, y: frame.maxY - colorSwitch.size.height)
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width/2)
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories_cs.switchCategory
        colorSwitch.zPosition = ZPositions_cs.colorSwitch
        colorSwitch.zRotation = -.pi/4
        colorSwitch.physicsBody?.isDynamic = false
        addChild(colorSwitch)
        
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 60.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.zPosition = ZPositions_cs.label
        addChild(scoreLabel)
        
        spawnBall()
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "\(score)"
    }
    
    func spawnBall() {
        
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors_cs.colors[currentColorIndex!], size: CGSize(width: frame.size.width * 0.08, height: frame.size.width * 0.08))
        ball.colorBlendFactor = 1.0
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: frame.maxY - (colorSwitch.size.height*3))
        ball.zPosition = ZPositions_cs.ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCategories_cs.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories_cs.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories_cs.edgeCategory
        addChild(ball)
    }
    
    func turnWheelForever() {
        turnWheel()
    }
    
    func turnWheel() {
        
        let rotateAction = SKAction.rotate(byAngle: .pi/2, duration: 2.0)
        
        
        let switchAction = SKAction.run {
            if let newState = SwitchState_cs(rawValue: self.switchState.rawValue + 1) {
                self.switchState = newState
            } else {
                self.switchState = .green
            }
            if self.score > self.scoreCheck {
                self.scoreCheck += 1
                self.switchIncrease *= 0.99
                self.switchSpeed += self.switchIncrease
                self.colorSwitch.speed = CGFloat(self.switchSpeed)
            }
            
        }
        
        colorSwitch.run(SKAction.repeatForever(SKAction.sequence([rotateAction, switchAction])))
    }
    
    func gameOver() {
        
        UserDefaults.standard.set(score, forKey: "RecentScore_cs")
        if score > UserDefaults.standard.integer(forKey: "HighScore_cs") {
            UserDefaults.standard.set(score, forKey: "HighScore_cs")
        }
        
        let menuScene = MenuScene_cs(size: view!.bounds.size)
        menuScene.gameVC = gameVC

        view!.presentScene(menuScene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                
                let menuScene = MenuScene_cs(size: view!.bounds.size)
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
                    self.isPaused = false
                    isGamePaused = false
                    pauseButton.texture = SKTexture(imageNamed: "PauseButtonWhite")
                    self.speed = 1.0
                    self.physicsWorld.speed = 1.0
                }
            }
            
        
        if ball != nil && isGamePaused == false && atPoint(location).name != "PauseButton"  {
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            let impulse = CGVector(dx: 0, dy: (ball.physicsBody?.mass)! * 650)
            ball.run(SKAction.applyImpulse(impulse, duration: 0.001))
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
    
}

extension GameScene_cs: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == PhysicsCategories_cs.ballCategory | PhysicsCategories_cs.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    //run(SKAction.playSoundFileNamed("bling.wav", waitForCompletion: false))
                    score += 1
                    updateScoreLabel()
                    ball.run(SKAction.fadeOut(withDuration: 0.25), completion: {
                        ball.removeFromParent()
                        self.spawnBall()
                    })
                } else {
                    ball.physicsBody?.isDynamic = false
                    colorSwitch.removeAllActions()
                    let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
                    let actionBack = SKAction.wait(forDuration: 2.0)
                    
                    self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                        self.gameOver()
                    })
                }
            }
        }
    }
    
}
