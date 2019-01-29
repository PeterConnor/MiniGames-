//
//  GameScene_pd.swift
//  MiniGames!
//
//  Created by Pete Connor on 6/30/18.
//  Copyright © 2018 c0nman. All rights reserved.
//

import SpriteKit

struct CollisionBitMask_evade {
    static let Player: UInt32 = 0x00
    static let Obstacle: UInt32 = 0x01
}

class GameScene_evade: SKScene, SKPhysicsContactDelegate {
    
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
                blurr2.texture = SKTexture(imageNamed: "BlueNum\(tens)")
                scoreLabel1.texture = SKTexture(imageNamed: "num\(hundreds)")
                blurr1.texture = SKTexture(imageNamed: "BlueNumBlueNum\(hundreds)")

            }

            if score % 10 == 0 && score % 100 != 0 {
                ones = 0
                tens += 1
                scoreLabel2.texture = SKTexture(imageNamed: "num\(tens)")
                blurr2.texture = SKTexture(imageNamed: "BlueNum\(tens)")

                
            }
            scoreLabel3.texture = SKTexture(imageNamed: "num\(ones)")
            blurr3.texture = SKTexture(imageNamed: "BlueNum\(ones)")

            if score >= 999 {
                scoreLabel1.texture = SKTexture(imageNamed: "num9")
                blurr1.texture = SKTexture(imageNamed: "BlueNum9")

                scoreLabel2.texture = SKTexture(imageNamed: "num9")
                blurr2.texture = SKTexture(imageNamed: "BlueNum9")

                scoreLabel3.texture = SKTexture(imageNamed: "num9")
                blurr3.texture = SKTexture(imageNamed: "BlueNum9")


            }
        }
    }
    
    var player = SKSpriteNode()
    var tapToStart = SKSpriteNode()
    var isLeft = false
    var canMove = false

    var obstacleList = [SKSpriteNode]()
    var obstacleScoreList = [SKSpriteNode]()
    var firstObstacleNumber = 0
    
    var gap: CGFloat = 200.0

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_evade.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addBackButton()
        addPauseButton()
        addPlayer()
        addPlayerBlurr()
        addScoreLabels()
        addBackground()
        addTapToStart()
        
        view.showsNodeCount = true
        //view.showsPhysics = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        canMove = true
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                let menuScene = MenuScene(fileNamed: "MenuScene")
                menuScene?.scaleMode = .aspectFit
                menuScene?.gameName = "evade"
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
                    pauseButtonBlurr.texture = SKTexture(imageNamed: "BluePauseButtonBlurr")
                    self.speed = 1.0
                    self.physicsWorld.speed = 1.0
                }
            }
            
            if atPoint(location).name != "PauseButton" {
                if location.x > 375 {
                    isLeft = false
                } else {
                    isLeft = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if started {
            canMove = true
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !started {
            started = true
            tapToStart.removeFromParent()
        }
        canMove = false
    }
    
    @objc func pauseGame() {
        timeCheck = 1
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButton")
        pauseButtonBlurr.texture = SKTexture(imageNamed: "BluePlayButtonBlurr")
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "BackgroundWhite")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 1
        
        let backgroundBlurr = SKSpriteNode(imageNamed: "BackgroundRed")
        backgroundBlurr.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backgroundBlurr.size.width = self.size.width
        backgroundBlurr.size.height = self.size.height
        backgroundBlurr.zPosition = -1
        
        self.addChild(background)
        //self.addChild(backgroundBlurr)
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "Disc")
        player.position = CGPoint(x: self.size.width/2, y: 350)
        player.name = "PLAYER"
        player.physicsBody?.isDynamic = false
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = CollisionBitMask_evade.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = CollisionBitMask_evade.Obstacle
        addChild(player)
        player.zPosition = 3
    }
    
   
    
    func addPlayerBlurr() {
        let playerBlurr = SKSpriteNode(imageNamed: "GreenDiscBlurr")
        //playerBlurr.position = CGPoint(x: player.position.x, y: player.position.y)
        //playerBlurr.name = "PLAYER"
        //playerBlurr.physicsBody?.isDynamic = false
        //playerBlurr.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        //playerBlurr.physicsBody?.categoryBitMask = CollisionBitMask_evade.Player
        //playerBlurr.physicsBody?.collisionBitMask = 0
        //playerBlurr.physicsBody?.contactTestBitMask = CollisionBitMask_evade.Obstacle
        player.addChild(playerBlurr)
        playerBlurr.zPosition = -1
    }
    
    func addTapToStart() {
        tapToStart = SKSpriteNode(imageNamed: "TapToStart")
        tapToStart.position = CGPoint(x: self.size.width/2, y: 200)
        addChild(tapToStart)
        tapToStart.zPosition = 3
    }
    
    func addObstacles() {
        let preRandomNumber = 750 - gap
        let randomNumber = Int(arc4random_uniform(UInt32(preRandomNumber)))

        let obstacle1 = SKSpriteNode(imageNamed: "Obstacle")
        obstacle1.size = CGSize(width: 750, height: 45)
        //obstacle1.anchorPoint = CGPoint(x: 0, y: 0)
        obstacle1.position = CGPoint(x: self.size.width/2 - gap - CGFloat(randomNumber), y: 1334 + obstacle1.size.height)
        obstacle1.name = "OBSTACLE"
        obstacle1.physicsBody?.isDynamic = true
        obstacle1.physicsBody = SKPhysicsBody(rectangleOf: obstacle1.size)
        obstacle1.physicsBody?.categoryBitMask = CollisionBitMask_evade.Obstacle
        obstacle1.physicsBody?.collisionBitMask = 0
        obstacle1.zPosition = 1
        obstacleList.append(obstacle1)
        obstacleScoreList.append(obstacle1)
        firstObstacleNumber = 1
        addChild(obstacle1)
        
        
       let obstacleBlurr = SKSpriteNode(imageNamed: "ObstacleBlurr")
        obstacleBlurr.size = CGSize(width: 803, height: 98)
        obstacle1.addChild(obstacleBlurr)
        obstacleBlurr.zPosition = -1
        
        let obstacle2 = SKSpriteNode(imageNamed: "Obstacle")
        obstacle2.size = CGSize(width: 750, height: 45)
        //obstacle2.anchorPoint = CGPoint(x: 0, y: 0)
        obstacle2.position = CGPoint(x: obstacle1.position.x + obstacle1.size.width/2 + gap + obstacle2.size.width/2, y: 1334 + obstacle2.size.height)
        obstacle2.name = "OBSTACLE"
        obstacle2.physicsBody?.isDynamic = true
        obstacle2.physicsBody = SKPhysicsBody(rectangleOf: obstacle2.size)
        obstacle2.physicsBody?.categoryBitMask = CollisionBitMask_evade.Obstacle
        obstacle2.physicsBody?.collisionBitMask = 0
        obstacle2.zPosition = 1
        obstacleList.append(obstacle2)

        addChild(obstacle2)
        
        addMovement(obs: obstacle1)
        addMovement(obs: obstacle2)
        
        let obstacleBlurr2 = SKSpriteNode(imageNamed: "ObstacleBlurr")
        obstacleBlurr.size = CGSize(width: 803, height: 98)
        obstacle2.addChild(obstacleBlurr2)
        obstacleBlurr2.zPosition = -1
        
    }
    
    func addMovement(obs: SKSpriteNode) {
        var actionList = [SKAction]()
        
        actionList.append(SKAction.move(to: CGPoint(x: obs.position.x, y: 0), duration: 3))
        actionList.append(SKAction.removeFromParent())
        
        obs.run(SKAction.sequence(actionList))
    }
    
    func move(left: Bool) {
        if canMove && !isGameOver {
            if left {
                player.position.x -= 17
                
                if player.position.x < 0 {
                    player.position.x = 0
                }
            } else {
                player.position.x += 17
                if player.position.x > 750 {
                    player.position.x = 750
                }
            }
        }
    }
    
    var lastUpdate = TimeInterval()
    var lastYieldTimeInterval = TimeInterval()
    var lastYieldTimeInterval2 = TimeInterval()
    var timeCheck = 0
        
    override func update(_ currentTime: TimeInterval) {
        
        if firstObstacleNumber == 1 {
            if obstacleScoreList[0].position.y < player.position.y {
            obstacleScoreList.removeFirst()
                score += 1
                if gap > 110 {
                    gap -= 1
                }
            }
        }
        
        if isGamePaused == false && isGameOver == false {
            if timeCheck == 1 {
                lastUpdate = currentTime
                timeCheck = 0
            }
            let timeSinceLastUpdate = currentTime - lastUpdate
            lastUpdate = currentTime
            lastYieldTimeInterval += timeSinceLastUpdate
            lastYieldTimeInterval2 += timeSinceLastUpdate
            if lastYieldTimeInterval2 > 0.01 {
                lastYieldTimeInterval2 = 0
                move(left: isLeft)
            }
            if lastYieldTimeInterval > 0.8 {
                lastYieldTimeInterval = 0
                if started {
                    addObstacles()
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "PLAYER" || contact.bodyA.node?.name == "OBSTACLE" {
            isGameOver = true
            player.isUserInteractionEnabled = false
            
            for i in obstacleList {
                i.removeAllActions()
            }

            let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
            let actionBack = SKAction.wait(forDuration: 2.0)
            
            self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                self.gameOver()
            })
        }
    }
    
    func gameOver() {
        
        UserDefaults.standard.set(score, forKey: "RecentScore_evade")
        if score > UserDefaults.standard.integer(forKey: "HighScore_evade") {
            UserDefaults.standard.set(score, forKey: "HighScore_evade")
        }
        
            let scene = MenuScene(fileNamed: "MenuScene")
            scene?.scaleMode = .aspectFit
            scene?.gameVC = self.gameVC
            scene?.gameName = "evade"
            
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
        
        pauseButtonBlurr = SKSpriteNode(imageNamed: "BluePauseButtonBlurr")
        //pauseButtonBlurr.size = CGSize(width: 72.4, height: 104.7)
        pauseButton.addChild(pauseButtonBlurr)
        pauseButtonBlurr.zPosition = -1
        
        pauseButton.position = CGPoint(x: 750 - pauseButtonBlurr.size.width/2 - 25, y: 1334 - pauseButtonBlurr.size.height/2 - 25)
        
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
}
