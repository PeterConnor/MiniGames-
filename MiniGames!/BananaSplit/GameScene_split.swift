//
//  GameScene_pd.swift
//  MiniGames!
//
//  Created by Pete Connor on 6/30/18.
//  Copyright © 2018 c0nman. All rights reserved.
//

import SpriteKit

struct CollisionBitMask_split {
    static let Player: UInt32 = 0x00
    static let Obstacle: UInt32 = 0x01
}

class GameScene_split: SKScene, SKPhysicsContactDelegate {
    
    weak var gameVC: GameViewController2?
    
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
    
    var player: SKSpriteNode!
    var isLeft = false
    var canMove = false

    var obstacleList = [SKSpriteNode]()
    var obstacleScoreList = [SKSpriteNode]()
    var firstObstacleNumber = 0
    
    var gap: CGFloat = 175.0

    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_split.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        addBackButton()
        addPauseButton()
        addPlayer()
        addPlayerBlurr()
        addScoreLabels()
        
        view.showsNodeCount = true
        //view.showsPhysics = true
        
        print(self.size)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        var canMove = true
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                let menuScene = MenuScene_split(fileNamed: "MenuScene_Split")
                menuScene?.scaleMode = .aspectFit
                menuScene?.gameName = "split"
                menuScene?.gameVC = gameVC
                
                self.view?.presentScene(menuScene!, transition: SKTransition.doorway(withDuration: 1))
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
        canMove = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "Disc")
        player.position = CGPoint(x: self.size.width/2, y: 250)
        player.name = "PLAYER"
        player.physicsBody?.isDynamic = false
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = CollisionBitMask_split.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = CollisionBitMask_split.Obstacle
        addChild(player)
        player.zPosition = 2
    }
    
    func addPlayerBlurr() {
        let playerBlurr = SKSpriteNode(imageNamed: "GreenDiscBlurr")
        //playerBlurr.position = CGPoint(x: player.position.x, y: player.position.y)
        //playerBlurr.name = "PLAYER"
        //playerBlurr.physicsBody?.isDynamic = false
        //playerBlurr.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        //playerBlurr.physicsBody?.categoryBitMask = CollisionBitMask_split.Player
        //playerBlurr.physicsBody?.collisionBitMask = 0
        //playerBlurr.physicsBody?.contactTestBitMask = CollisionBitMask_split.Obstacle
        player.addChild(playerBlurr)
        playerBlurr.zPosition = -1
    }
    
    func addObstacles() {
        
        let preRandomNumber = 750 - gap
        var randomNumber = Int(arc4random_uniform(UInt32(preRandomNumber)))
        print(randomNumber)

        var obstacle1 = SKSpriteNode(imageNamed: "Obstacle")
        obstacle1.size = CGSize(width: 750, height: 45)
        //obstacle1.anchorPoint = CGPoint(x: 0, y: 0)
        obstacle1.position = CGPoint(x: self.size.width/2 - gap - CGFloat(randomNumber), y: 1334 + obstacle1.size.height)
        obstacle1.name = "OBSTACLE"
        obstacle1.physicsBody?.isDynamic = true
        obstacle1.physicsBody = SKPhysicsBody(rectangleOf: obstacle1.size)
        obstacle1.physicsBody?.categoryBitMask = CollisionBitMask_split.Obstacle
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
        
        var obstacle2 = SKSpriteNode(imageNamed: "Obstacle")
        obstacle2.size = CGSize(width: 750, height: 45)
        //obstacle2.anchorPoint = CGPoint(x: 0, y: 0)
        obstacle2.position = CGPoint(x: obstacle1.position.x + obstacle1.size.width/2 + gap + obstacle2.size.width/2, y: 1334 + obstacle2.size.height)
        obstacle2.name = "OBSTACLE"
        obstacle2.physicsBody?.isDynamic = true
        obstacle2.physicsBody = SKPhysicsBody(rectangleOf: obstacle2.size)
        obstacle2.physicsBody?.categoryBitMask = CollisionBitMask_split.Obstacle
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
                player.position.x -= 15
                
                if player.position.x < 0 {
                    player.position.x = 0
                }
            } else {
                player.position.x += 15
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
            }
        }
        
        if isGamePaused == false && isGameOver == false {
            if timeCheck == 1 {
                lastUpdate = currentTime
                timeCheck = 0
            }
            var timeSinceLastUpdate = currentTime - lastUpdate
            lastUpdate = currentTime
            lastYieldTimeInterval += timeSinceLastUpdate
            lastYieldTimeInterval2 += timeSinceLastUpdate
            if lastYieldTimeInterval2 > 0.01 {
                lastYieldTimeInterval2 = 0
                move(left: isLeft)
            }
            if lastYieldTimeInterval > 0.8 {
                lastYieldTimeInterval = 0
                addObstacles()
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
        
        UserDefaults.standard.set(score, forKey: "RecentScore_split")
        if score > UserDefaults.standard.integer(forKey: "HighScore_split") {
            UserDefaults.standard.set(score, forKey: "HighScore_split")
        }
        
        if let view = self.view as SKView? {
            let scene = MenuScene_split(fileNamed: "MenuScene_Split")
            scene?.scaleMode = .aspectFit
            scene?.gameVC = self.gameVC
            scene?.gameName = "split"
            view.presentScene(scene)
        }
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
        scoreLabel1.zPosition = 2
        scoreLabel1.position = CGPoint(x: self.size.width/2 - scoreLabel1.size.width - 20, y: 1334 - scoreLabel1.size.height/2 - 40)
        scoreLabel2.zPosition = 2
        scoreLabel2.position = CGPoint(x: self.size.width/2, y: 1334 - scoreLabel2.size.height/2 - 40)
        scoreLabel3.zPosition = 2
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

/*class GameScene_split: SKScene, SKPhysicsContactDelegate {
    
    var isGameOver = false
    var isGamePaused = false
    
    var compareNum = 10
 
    var obstacleList = [SKSpriteNode]()
    var obstacleList2 = [SKSpriteNode]()
    
    var firstObstacleNumber = 0
    
    weak var gameVC: GameViewController2?
    
    var player: SKSpriteNode!
    var player2: SKSpriteNode!
    
    var pauseButton = SKSpriteNode()
    
    var initialPlayerPosition: CGPoint!
    
    override func didMove(to view: SKView) {
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_split.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        backgroundColor = SKColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        addPlayer()
        addScoreLabel()
        addBackButton()
        addPauseButton()
        //addRow(type: .oneM)
    }
    
    func addRandomRow() {
        var randomNumber = Int(arc4random_uniform(9))
        
        while randomNumber == compareNum {
            randomNumber = Int(arc4random_uniform(9))
        }
        
        compareNum = randomNumber
        
        switch randomNumber {
        case 0:
            addRow(type: RowType(rawValue: 0)!)
            break
        case 1:
            addRow(type: RowType(rawValue: 1)!)
            break
        case 2:
            addRow(type: RowType(rawValue: 2)!)
            break
        case 3:
            addRow(type: RowType(rawValue: 3)!)
            break
        case 4:
            addRow(type: RowType(rawValue: 4)!)
            break
        case 5:
            addRow(type: RowType(rawValue: 5)!)
            break
        case 6:
            addRow(type: RowType(rawValue: 6)!)
        case 7:
            addRow(type: RowType(rawValue: 7)!)
        case 8:
            addRow(type: RowType(rawValue: 8)!)
            break
        default:
            break
        }
    }
    
    var lastUpdate = TimeInterval()
    var lastYieldTimeInterval = TimeInterval()
    var timeCheck = 0
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: CFTimeInterval) {
        if isGameOver == false && isGamePaused == false {
            lastYieldTimeInterval += timeSinceLastUpdate
            if lastYieldTimeInterval > 0.6 {
                lastYieldTimeInterval = 0
                addRandomRow()
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        if isGamePaused == false && isGameOver == false {
            if timeCheck == 1 {
                lastUpdate = currentTime
                timeCheck = 0
            }
            var timeSinceLastUpdate = currentTime - lastUpdate
            lastUpdate = currentTime
            lastYieldTimeInterval += timeSinceLastUpdate
            if lastYieldTimeInterval > 0.6 {
                lastYieldTimeInterval = 0
                addRandomRow()
            }
        }
        
        
        
        
        
        if firstObstacleNumber == 1 {
            if obstacleList[0].position.y < player.position.y {
                score += 1
                obstacleList.removeFirst()
            }
        }
        
        for (index, object) in obstacleList2.enumerated() {
            if object.position.y < frame.minX - 20 {
                obstacleList2.remove(at: index)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {

        let location = touch.location(in: self)
        
        if atPoint(location).name == "BackButton" {
            let menuScene = MenuScene_split(size: view!.bounds.size)
            menuScene.scaleMode = .aspectFill
            menuScene.gameVC = gameVC

            self.view?.presentScene(menuScene, transition: SKTransition.doorway(withDuration: 1))
            }
            
            if atPoint(location).name == "PauseButton" && isGameOver == false {
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
    
    @objc func pauseGame() {
        timeCheck = 1
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButtonWhite")
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver == false  && isGamePaused == false {
            if let touch = touches.first {
                let maximumPossibleForce = touch.maximumPossibleForce
                let force = touch.force
                let normalizedForce = force/maximumPossibleForce
                
                player.position.x = (self.size.width / 2) - normalizedForce * (self.size.width / 2 - 25)
                player2.position.x = (self.size.width / 2) + normalizedForce * (self.size.width / 2 - 25)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver == false {
            resetPlayerPosition()
        }
        
    }
    
    func resetPlayerPosition() {
        player.position = initialPlayerPosition
        player2.position = initialPlayerPosition
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "PLAYER" {
            isGameOver = true
            player.isUserInteractionEnabled = false
            player2.isUserInteractionEnabled = false
            //self.isUserInteractionEnabled = false
            
            for i in obstacleList {
                i.removeAllActions()
            }
            for i in obstacleList2 {
                i.removeAllActions()
            }
            let actionRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.25)
            let actionBack = SKAction.wait(forDuration: 2.0)
            
            self.scene?.run(SKAction.sequence([actionRed, actionBack]), completion: { () -> Void in
                self.gameOver()
            })
        }
    }
    
}

extension GameScene_split {
 
    func addObstacle(type: ObstacleType) -> SKSpriteNode {
        let obstacle = SKSpriteNode()
        obstacle.size = CGSize(width: 0, height: self.frame.size.height * 0.03)
        obstacle.name = "OBSTACLE"
        obstacle.physicsBody?.isDynamic = true
        
        switch type {
        case .Small:
            obstacle.texture = SKTexture(imageNamed: "SplitBarSmall")
            obstacle.size.width = self.size.width * 0.25
            //480 x 60
            break
        case .Medium:
            obstacle.texture = SKTexture(imageNamed: "SplitBarSmall")
            obstacle.size.width = self.size.width * 0.4
            //768
            break
        case .Large:
            obstacle.texture = SKTexture(imageNamed: "SplitBarLarge")

            obstacle.size.width = self.size.width * 0.75
            //1440
        case .Tiny:
            obstacle.texture = SKTexture(imageNamed: "SplitBarTiny")
            obstacle.size.width = self.size.width * 0.15
            break
        }
        
        obstacle.position = CGPoint(x: 0, y: self.size.height + obstacle.size.height)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.categoryBitMask = CollisionBitMask_split.Obstacle
        obstacle.physicsBody?.collisionBitMask = 0
        
        return obstacle
    }
    
    func addMovement(obstacle: SKSpriteNode) {
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: obstacle.position.x, y: -obstacle.size.height), duration: 3))
        actionArray.append(SKAction.removeFromParent())
        
        obstacle.run(SKAction.sequence(actionArray))
    }
    
    func addRow(type: RowType) {
        switch type {
        case .oneS:
            let obst = addObstacle(type: .Small)
            obst.position = CGPoint(x: self.size.width / 2, y: obst.position.y)
            obstacleList.append(obst)
            obstacleList2.append(obst)
            if firstObstacleNumber == 0 {
                firstObstacleNumber = 1
            }
            addMovement(obstacle: obst)
            addChild(obst)
            break
        case .oneM:
            let obst = addObstacle(type: .Medium)
            obst.position = CGPoint(x: self.size.width / 2, y: obst.position.y)
            obstacleList.append(obst)
            obstacleList2.append(obst)
            if firstObstacleNumber == 0 {
                firstObstacleNumber = 1
            }
            addMovement(obstacle: obst)
            addChild(obst)
            break
        case .oneL:
            let obst = addObstacle(type: .Large)
            obst.position = CGPoint(x: self.size.width / 2, y: obst.position.y)
            obstacleList.append(obst)
            obstacleList2.append(obst)
            if firstObstacleNumber == 0 {
                firstObstacleNumber = 1
            }
            addMovement(obstacle: obst)
            addChild(obst)
            break
        case .twoS:
            let obst1 = addObstacle(type: .Small)
            let obst2 = addObstacle(type: .Small)
            
            obst1.position = CGPoint(x: obst1.size.width + 50, y: obst1.position.y)
            obst2.position = CGPoint(x: self.size.width - obst2.size.width - 50, y: obst1.position.y)
            obstacleList.append(obst1)
            obstacleList2.append(obst2)
            obstacleList2.append(obst1)
            if firstObstacleNumber == 0 {
                firstObstacleNumber = 1
            }
            
            addMovement(obstacle: obst1)
            addMovement(obstacle: obst2)
            
            addChild(obst1)
            addChild(obst2)
            
            break
        case .twoM:
            let obst1 = addObstacle(type: .Medium)
            let obst2 = addObstacle(type: .Medium)
            
            obst1.position = CGPoint(x: obst1.size.width/2, y: obst1.position.y)
            obst2.position = CGPoint(x: self.size.width - obst2.size.width/2, y: obst1.position.y)
            obstacleList.append(obst1)
            obstacleList2.append(obst2)
            obstacleList2.append(obst1)
            if firstObstacleNumber == 0 {
                firstObstacleNumber = 1
            }
            
            addMovement(obstacle: obst1)
            addMovement(obstacle: obst2)
            
            addChild(obst1)
            addChild(obst2)
            break
        case .threeTiny:
            let obst1 = addObstacle(type: .Tiny)
            let obst2 = addObstacle(type: .Tiny)
            let obst3 = addObstacle(type: .Tiny)

            obst1.position = CGPoint(x: obst1.size.width/2, y: obst1.position.y)
            obst2.position = CGPoint(x: self.size.width - obst2.size.width/2, y: obst1.position.y)
            obst3.position = CGPoint(x: self.size.width/2, y: obst1.position.y)
            obstacleList.append(obst1)
            obstacleList2.append(obst2)
            obstacleList2.append(obst3)
            obstacleList2.append(obst1)
            
            if firstObstacleNumber == 0 {
                firstObstacleNumber = 1
            }
            
            addMovement(obstacle: obst1)
            addMovement(obstacle: obst2)
            addMovement(obstacle: obst3)
            
            addChild(obst1)
            addChild(obst2)
            addChild(obst3)
            
            break
        case .twoSmallOneTiny:
            let obst1 = addObstacle(type: .Small)
            let obst2 = addObstacle(type: .Small)
            let obst3 = addObstacle(type: .Tiny)
            
            obst1.position = CGPoint(x: obst1.size.width/2, y: obst1.position.y)
            obst2.position = CGPoint(x: self.size.width - obst2.size.width/2, y: obst1.position.y)
            obst3.position = CGPoint(x: self.size.width/2, y: obst1.position.y)
            obstacleList.append(obst1)
            obstacleList2.append(obst2)
            obstacleList2.append(obst3)
            obstacleList2.append(obst1)
            
            if firstObstacleNumber == 0 {
                firstObstacleNumber = 1
            }
            
            addMovement(obstacle: obst1)
            addMovement(obstacle: obst2)
            addMovement(obstacle: obst3)
            
            addChild(obst1)
            addChild(obst2)
            addChild(obst3)
            
            break
        case .oneMediumTwoTiny:
            let obst1 = addObstacle(type: .Tiny)
            let obst2 = addObstacle(type: .Tiny)
            let obst3 = addObstacle(type: .Medium)
            
            obst1.position = CGPoint(x: obst1.size.width/2, y: obst1.position.y)
            obst2.position = CGPoint(x: self.size.width - obst2.size.width/2, y: obst1.position.y)
            obst3.position = CGPoint(x: self.size.width/2, y: obst1.position.y)
            obstacleList.append(obst1)
            obstacleList2.append(obst2)
            obstacleList2.append(obst3)
            obstacleList2.append(obst1)
            
            
            if firstObstacleNumber == 0 {
                firstObstacleNumber = 1
            }
            
            addMovement(obstacle: obst1)
            addMovement(obstacle: obst2)
            addMovement(obstacle: obst3)
            
            addChild(obst1)
            addChild(obst2)
            addChild(obst3)
            
            break
        case .threeS:
            let obst1 = addObstacle(type: .Small)
            let obst2 = addObstacle(type: .Small)
            let obst3 = addObstacle(type: .Small)
            
            obst1.position = CGPoint(x: obst1.size.width/2, y: obst1.position.y)
            obst2.position = CGPoint(x: self.size.width - obst2.size.width/2, y: obst1.position.y)
            obst3.position = CGPoint(x: self.size.width/2, y: obst1.position.y)
            obstacleList.append(obst1)
            obstacleList2.append(obst2)
            obstacleList2.append(obst3)
            obstacleList2.append(obst1)

            if firstObstacleNumber == 0 {
                firstObstacleNumber = 1
            }
            
            addMovement(obstacle: obst1)
            addMovement(obstacle: obst2)
            addMovement(obstacle: obst3)
            
            addChild(obst1)
            addChild(obst2)
            addChild(obst3)
        
            break
        }
    }
    
    func addScoreLabel() {
        scoreLabel.zPosition = 2
        scoreLabel.fontSize = 80
        scoreLabel.fontColor = .yellow
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: frame.midX, y: self.size.height - (scoreLabel.frame.height * 2))
        addChild(scoreLabel)
    }
 
}*/
