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
    var tapToStart = SKSpriteNode()
    var isLeft = false
    var canMove = false

    var obstacleList = [SKSpriteNode]()
    var obstacleScoreList = [SKSpriteNode]()
    var firstObstacleNumber = 0
    
    var gap: CGFloat = 350.0
    var gapDecrease: CGFloat = 2

    override func didMove(to view: SKView) {
        
        numAtlas.preload {
            // Do something once texture atlas has loaded
        }
        
        self.physicsWorld.contactDelegate = self

        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_evade.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addBackButton()
        addPauseButton()
        addPlayer()
        addPlayerblur()
        addScoreLabels()
        addBackground()
        addTapToStart()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if started && !isPaused {
            canMove = true
        }
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
                    pauseButtonblur.texture = SKTexture(imageNamed: "BluePauseButtonblur")
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
        pauseButtonblur.texture = SKTexture(imageNamed: "BluePlayButtonblur")
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "BackgroundWhite")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.width = self.size.width
        background.size.height = self.size.height
        background.zPosition = 1
        
        let backgroundblur = SKSpriteNode(imageNamed: "BackgroundRed")
        backgroundblur.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backgroundblur.size.width = self.size.width
        backgroundblur.size.height = self.size.height
        backgroundblur.zPosition = -1
        
        self.addChild(background)
        //self.addChild(backgroundblur)
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
    
   
    
    func addPlayerblur() {
        let playerblur = SKSpriteNode(imageNamed: "GreenDiscblur")
        //playerblur.position = CGPoint(x: player.position.x, y: player.position.y)
        //playerblur.name = "PLAYER"
        //playerblur.physicsBody?.isDynamic = false
        //playerblur.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        //playerblur.physicsBody?.categoryBitMask = CollisionBitMask_evade.Player
        //playerblur.physicsBody?.collisionBitMask = 0
        //playerblur.physicsBody?.contactTestBitMask = CollisionBitMask_evade.Obstacle
        player.addChild(playerblur)
        playerblur.zPosition = -1
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
        
        
       let obstacleblur = SKSpriteNode(imageNamed: "Obstacleblur")
        obstacleblur.size = CGSize(width: 803, height: 98)
        obstacle1.addChild(obstacleblur)
        obstacleblur.zPosition = -1
        
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
        
        let obstacleblur2 = SKSpriteNode(imageNamed: "Obstacleblur")
        obstacleblur.size = CGSize(width: 803, height: 98)
        obstacle2.addChild(obstacleblur2)
        obstacleblur2.zPosition = -1
        
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
                if gap > 250 {
                    gapDecrease = 4
                    gap -= gapDecrease
                } else if gap > 200 {
                    gapDecrease = 2
                    gap -= gapDecrease
                } else if gap > 175 {
                    gapDecrease = 0.5
                    gap -= gapDecrease
                } else if gap > 150 {
                    gapDecrease = 0.4
                    gap -= gapDecrease
                } else if gap > 130 {
                    gapDecrease = 0.3
                    gap -= gapDecrease
                } else if gap > 125 {
                    gapDecrease = 0.2
                    gap -= gapDecrease
                } else if gap > 120 {
                    gapDecrease = 0.1
                    gap -= gapDecrease
                } else if gap > 112 {
                    gapDecrease = 0.05
                    gap -= gapDecrease
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
        
        let backButtonblur = SKSpriteNode(imageNamed: "BlueBackButtonblur")
        //ZbackButtonblur.size = CGSize(width: 67.2, height: 115.8)
        backButton.addChild(backButtonblur)
        backButtonblur.zPosition = -1
        
        backButton.position = CGPoint(x: 0 + backButtonblur.size.width/2 + 25, y: 1334 - backButtonblur.size.height/2 - 25)
        
    }
    
    func addPauseButton() {
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "PauseButton"))
        pauseButton.name = "PauseButton"
        //pauseButton.size.width = 42.7
        //pauseButton.size.height = 75
        
        pauseButton.zPosition = 6
        addChild(pauseButton)
        
        pauseButtonblur = SKSpriteNode(imageNamed: "BluePauseButtonblur")
        //pauseButtonblur.size = CGSize(width: 72.4, height: 104.7)
        pauseButton.addChild(pauseButtonblur)
        pauseButtonblur.zPosition = -1
        
        pauseButton.position = CGPoint(x: 750 - pauseButtonblur.size.width/2 - 25, y: 1334 - pauseButtonblur.size.height/2 - 25)
        
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
}
