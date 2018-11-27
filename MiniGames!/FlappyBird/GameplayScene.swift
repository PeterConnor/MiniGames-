//
//  GameplayScene.swift
//  FlappyBird
//
//  Created by Pete Connor on 4/18/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import SpriteKit

class GameplayScene: SKScene, SKPhysicsContactDelegate {
    
    weak var gameVC: GameViewController2?
    
    var isGamePaused = false
    
    var pauseButton = SKSpriteNode()
    
    var bird = Bird()
    var pipesHolder = SKNode()
    var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var score = 0 {
        didSet {
            if score == scoreCheck && pipeNumber >= 575 {
                scoreCheck += 1
                //gameTimer.invalidate()
                pipeNumber -= 5
                
            }
        }
    }
    
    var gameStarted = false
    var isAlive = false
    
    var press = SKSpriteNode()
    
    var pipeNumber = 700
    var gameTimer = Timer()
    var scoreCheck = 1
    
    override func didMove(to view: SKView) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameplayScene.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        initialize()
        addPauseButton()
    }
    
    var lastUpdate = TimeInterval()
    var lastYieldTimeInterval = TimeInterval()
    var timeCheck = 0
    
    /*func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: CFTimeInterval) {
        if isAlive == true && isGamePaused == false && gameStarted {
            lastYieldTimeInterval += timeSinceLastUpdate
            if lastYieldTimeInterval > 2 {
                lastYieldTimeInterval = 0
                spawnObstacles()
            }
        }
    }*/
    
    
    override func update(_ currentTime: TimeInterval) {
        if gameStarted && !isAlive {
            bird.texture = SKTexture(imageNamed: "Blue 4")
        }
        if isAlive && isGamePaused == false {
            moveBackgroundsAndGrounds()
        }
        
        if bird.position.y - bird.size.height/2 > self.frame.maxY {
            birdDied()
        }
        
        if isGamePaused == false && isAlive == true {
            if timeCheck == 1 {
                lastUpdate = currentTime
                timeCheck = 0
            }
            var timeSinceLastUpdate = currentTime - lastUpdate
            lastUpdate = currentTime
            lastYieldTimeInterval += timeSinceLastUpdate
            if lastYieldTimeInterval > 2 {
                lastYieldTimeInterval = 0
                spawnObstacles()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
        
        if gameStarted == false {
            isAlive = true
            scoreLabel.text = "0"
            gameStarted = true
            press.removeFromParent()
            //gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(spawnObstacles), userInfo: nil, repeats: true)
            bird.physicsBody?.affectedByGravity = true
            bird.flap()
        }
        if isAlive && isGamePaused == false && atPoint(location).name != "PauseButton" {
            bird.flap()
        }
        
            if atPoint(location).name == "Retry" {
                self.removeAllActions()
                self.removeAllChildren()
                initialize()
            }
            
            if atPoint(location).name == "BackButton" {
                let mainMenu = MainMenuScene(size: view!.bounds.size) 
                mainMenu.scaleMode = .aspectFill
                mainMenu.gameVC = gameVC
                self.view?.presentScene(mainMenu, transition: SKTransition.doorway(withDuration: 1))
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
                    moveBackgroundsAndGrounds()
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "Bird" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Bird" && secondBody.node?.name == "Score" {
            incrementScore()
        } else if firstBody.node?.name == "Bird" && secondBody.node?.name == "Pipe" {
            if isAlive {
                self.isUserInteractionEnabled = false
                birdDied()
                bird.texture = SKTexture(imageNamed: "Blue 4")
            }
        } else if firstBody.node?.name == "Bird" && secondBody.node?.name == "Ground" {
            if isAlive {
                self.isUserInteractionEnabled = false
                birdDied()
            }
        }
    }
    
    func initialize() {
        
        physicsWorld.contactDelegate = self
        
        createBird()
        createBackgrounds()
        createGrounds()
        createLabel()
        addBackButton()
        //createInstructions()
        
        gameStarted = false
        isAlive = false
        score = 0
    }
    
    func createInstructions() {
        press = SKSpriteNode(imageNamed: "Press")
        press.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        press.position = CGPoint(x: 0, y: 0)
        press.setScale(1.8)
        press.zPosition = 10
        self.addChild(press)
    }
    
    func createBird() {
        bird = Bird(imageNamed: "\(GameManager.instance.getBird()) 1")
        bird.initialize()
        bird.position = CGPoint(x: -50, y: 0)
        self.addChild(bird)
    }
    
    func createBackgrounds() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG Day")
            bg.name = "BG"
            bg.zPosition = 0
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 0)
            self.addChild(bg)
        }
    }
    
    func createGrounds() {
        for i in 0...2 {
            let ground = SKSpriteNode(imageNamed: "Ground")
            ground.name = "Ground"
            ground.zPosition = 4
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: -(self.frame.size.height/2) + 50)
            ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ground.size.width, height: ground.size.height - 20))
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.categoryBitMask = ColliderType.Ground
            self.addChild(ground)
        }
    }
    
    func moveBackgroundsAndGrounds() {
        enumerateChildNodes(withName: "BG", using: ({
            (node, error) in
            
            node.position.x -= 4.5
            if node.position.x < -(self.frame.width) {
               node.position.x += self.frame.width * 3
            }
            
        }))
        
        enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in
            
            node.position.x -= 2
            if node.position.x < -(self.frame.width) {
                node.position.x += self.frame.width * 3
            }
            
        }))
    }
    
    func createPipes() {
        pipesHolder = SKNode()
        pipesHolder.name = "Holder"
        
        let pipeUp = SKSpriteNode(imageNamed: "Pipe 1")
        let pipeDown = SKSpriteNode(imageNamed: "Pipe 1")
        
        let scoreNode = SKSpriteNode()
        scoreNode.color = SKColor.clear
        scoreNode.name = "Score"
        scoreNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scoreNode.position = CGPoint(x: 0, y: 0)
        scoreNode.size = CGSize(width: 5, height: 300)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.categoryBitMask = ColliderType.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        
        pipeUp.name = "Pipe"
        pipeUp.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pipeUp.physicsBody = SKPhysicsBody(rectangleOf: pipeUp.size)
        pipeUp.position = CGPoint(x: 0, y: pipeNumber)
        pipeUp.yScale = 1.5
        pipeUp.zRotation = CGFloat(Double.pi)
        pipeUp.physicsBody?.categoryBitMask = ColliderType.Pipes
        pipeUp.physicsBody?.affectedByGravity = false
        pipeUp.physicsBody?.isDynamic = false
        
        pipeDown.name = "Pipe"
        pipeDown.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pipeDown.physicsBody = SKPhysicsBody(rectangleOf: pipeDown.size)
        pipeDown.position = CGPoint(x: 0, y: -pipeNumber)
        pipeDown.yScale = 1.5
        pipeDown.physicsBody?.categoryBitMask = ColliderType.Pipes
        pipeDown.physicsBody?.affectedByGravity = false
        pipeDown.physicsBody?.isDynamic = false
        pipeDown.xScale = -1
        
        pipesHolder.zPosition = 5
        pipesHolder.position.x = self.frame.width + 100
        if pipeNumber > 580 {
            pipesHolder.position.y = CGFloat.randomBetweenNumbers(firstNum: -300, secondNum: 300)

        } else {
            pipesHolder.position.y = CGFloat.randomBetweenNumbers(firstNum: -250, secondNum: 250)

        }
        
        pipesHolder.addChild(pipeUp)
        pipesHolder.addChild(pipeDown)
        pipesHolder.addChild(scoreNode)
        
        self.addChild(pipesHolder)
        
        let destination = self.frame.width * 2
        let move = SKAction.moveTo(x: -destination, duration: 10)
        let remove = SKAction.removeFromParent()
        
        pipesHolder.run(SKAction.sequence([move, remove]), withKey: "Move")

    }
    
    @objc func spawnObstacles() {
        createPipes()
    }
    
    func createLabel() {
        scoreLabel.zPosition = 6
        scoreLabel.position = CGPoint(x: 0, y: 450)
        scoreLabel.fontSize = 120
        scoreLabel.text = "Tap!"
        self.addChild(scoreLabel)
        scoreLabel.fontColor = .blue
    }
    
    func incrementScore() {
        score += 1
        scoreLabel.text = "\(score)"
    }
    
    func birdDied() {
        
        gameTimer.invalidate()
        
        for child in children {
            if child.name == "Holder" {
                child.removeAction(forKey: "Move")
            }
        }
        
        isAlive = false
        bird.texture = bird.diedTexture
        
        UserDefaults.standard.set(score, forKey: "RecentScore_fb")
        if score > UserDefaults.standard.integer(forKey: "HighScore_fb") {
            UserDefaults.standard.set(score, forKey: "HighScore_fb")
        }
        
        self.run(SKAction.wait(forDuration: 2)) {
            let scene = MainMenuScene(size: self.view!.bounds.size)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                scene.gameVC = self.gameVC
                self.view!.presentScene(scene)
            

        }
        
       /* let highscore = GameManager.instance.getHighscore()
        
        if highscore < score {
            GameManager.instance.setHighscore(highscore: score)
            
        }
        
        let retry = SKSpriteNode(imageNamed: "Retry")
        let quit = SKSpriteNode(imageNamed: "Quit")
        
        retry.name = "Retry"
        retry.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        retry.position = CGPoint(x: -150, y: -150)
        retry.zPosition = 7
        retry.setScale(0)
        
        quit.name = "Quit"
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        quit.position = CGPoint(x: 150, y: -150)
        quit.zPosition = 7
        quit.setScale(0)
        
        let scaleUp = SKAction.scale(to: 1, duration: 0.5)
        retry.run(scaleUp)
        quit.run(scaleUp)
        
        self.addChild(retry)
        self.addChild(quit)
 
 */
        
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
    
}
