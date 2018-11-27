//
//  GameScene_sim.swift
//  MiniGames!
//
//  Created by Pete Connor on 6/24/18.
//  Copyright © 2018 c0nman. All rights reserved.
//

import SpriteKit

enum GameState_sim {
    case touchToBegin
    case memorizing
    case tapping
    case gameOver
}

class GameScene_sim: SKScene, SKPhysicsContactDelegate {
    
    weak var gameVC: GameViewController2?
    
    var isGamePaused = false
    var pauseButton = SKSpriteNode()
    var gameState: GameState_sim?
    
    var scoreLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var buttonSequence = [SKSpriteNode]()
    var buttonCount = 0
    var buttonIndex = 0
    var actionButton = SKLabelNode(fontNamed: "AvenirNext-Bold")

    
    
    override func didMove(to view: SKView) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_sim.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        self.physicsWorld.contactDelegate = self

        addBackButton()
        addPauseButton()
        addActionButton()
        
        
        gameState = .touchToBegin
    }
    
    func addButton() {
        var button = SKSpriteNode(imageNamed: "bbball")
        button.size = CGSize(width: 30, height: 30)
        var randomX = Int(arc4random_uniform(UInt32(650)) + 50)
        var randomY = Int(arc4random_uniform(UInt32(1150)) + 50)
        button.position = CGPoint(x: randomX, y: randomY)
        button.alpha = 0.2
        button.name = "button\(buttonCount)"
        buttonCount += 1
        buttonSequence.append(button)
        addChild(button)
    }
    
    func addActionButton() {
        actionButton.text = "Play Sequence"
        actionButton.fontSize = 30
        actionButton.fontColor = .white
        actionButton.position = CGPoint(x: self.size.width/2, y: 100)
        actionButton.name = "actionButton"
        self.addChild(actionButton)
    }
    
   func animateButtons() {
        addButton()
        for i in 0..<buttonSequence.count {
            
            let initialWait = SKAction.wait(forDuration: TimeInterval(0.5))
            
            let iWait = SKAction.wait(forDuration: TimeInterval(1 * CGFloat(i)))
            
            let alphaAction = SKAction.run {
                self.buttonSequence[i].alpha = 1
            }
            alphaAction.timingMode = .easeIn
            
            let waitAction = SKAction.wait(forDuration: TimeInterval(0.5))
            
            let alphaBack = SKAction.run {
                self.buttonSequence[i].alpha = 0.2
            }
            alphaBack.timingMode = .easeOut
            
            let finalAction = SKAction.run {
                if i == self.buttonSequence.count - 1 {
                    self.gameState = .tapping
                    self.actionButton.fontColor = .gray
                    self.actionButton.text = "Repeat Sequence"
                    self.isUserInteractionEnabled = true
                }
            }
            
            buttonSequence[i].run(SKAction.sequence([initialWait, iWait, alphaAction, waitAction, alphaBack]))
            
            let finalWait = SKAction.wait(forDuration: TimeInterval(CGFloat(buttonSequence.count)))
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: 0.25), finalWait, waitAction, finalAction]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                let menuScene = MenuScene_sim(size: view!.bounds.size)
                menuScene.scaleMode = .aspectFill
                menuScene.gameVC = gameVC
                
                self.view?.presentScene(menuScene, transition: SKTransition.doorway(withDuration: 1))
            }
            
            if gameState == .touchToBegin {
                if atPoint(location).name == "actionButton" {
                    gameState = .memorizing
                    actionButton.fontColor = .gray
                    actionButton.text = "Memorize Sequence"
                    self.isUserInteractionEnabled = false
                    animateButtons()
                }
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
            
            if gameState == .tapping {
                
                for i in 0..<buttonSequence.count {
                    if atPoint(location).name == buttonSequence[i].name {
                        
                        let alphaAction = SKAction.run {
                            self.buttonSequence[i].alpha = 1
                        }
                        buttonSequence[i].run(alphaAction, withKey: "alphaAction")
                    }
                }
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameState == .tapping {
            if let touch = touches.first {
                let location = touch.location(in: self)
                
                if gameState == .tapping || gameState == .touchToBegin || gameState == .gameOver {
                    for i in 0..<buttonSequence.count {
                        buttonSequence[i].alpha = 0.2
                    }
                }
            
            if atPoint(location).name == buttonSequence[buttonIndex].name {
                buttonIndex += 1
                if buttonIndex < buttonSequence.count {
                } else {
                    gameState = .touchToBegin
                    actionButton.text = "Correct!"
                    actionButton.fontColor = .green
                    buttonIndex = 0
                    let wait = SKAction.wait(forDuration: 0.75)
                    let run = SKAction.run {
                        self.actionButton.fontColor = .white
                        self.actionButton.text = "Play Sequence"
                        self.score += 1
                    }
                    self.run(SKAction.sequence([wait, run]))
                }
            } else if atPoint(location).name != buttonSequence[buttonIndex].name {
                gameOver()
            }
            
            if gameState == .gameOver {
                if atPoint(location).name == "actionButton" {
                    actionButton.fontColor = .white
                    actionButton.text = "Play Sequence"
                    gameState = .touchToBegin
                }
            }
        }
        }
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
        
        UserDefaults.standard.set(score, forKey: "RecentScore_sim")
        if score > UserDefaults.standard.integer(forKey: "HighScore_sim") {
            UserDefaults.standard.set(score, forKey: "HighScore_sim")
        }
        
        if let view = self.view as SKView? {
            let scene = MenuScene_sim(size: view.bounds.size)
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
}





/*import SpriteKit

enum GameState_sim {
    case touchToBegin
    case memorizing
    case tapping
    case gameOver
}

class GameScene_sim: SKScene {
    
    weak var gameVC: GameViewController2?
    
    //var isGamePaused = false

    var button0 = SKSpriteNode()
    var button1 = SKSpriteNode()
    var button2 = SKSpriteNode()
    var button3 = SKSpriteNode()
    
    var buttonList = [SKSpriteNode]()
    
    var buttonSequence = [Int]()
    
    var actionSequence = [SKSpriteNode]()
    
    var actionButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
    
    var gameState: GameState_sim!
    
    var buttonIndex = 0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    
    override func didMove(to view: SKView) {
        gameState = .touchToBegin
        backgroundColor = .white
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        createButtons()
        addButton()
        addScoreLabel()
        addBackButton()
        //addPauseButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first {
            let location = touch.location(in: self)
                
                if atPoint(location).name == "BackButton" {
                    
                    let menuScene = MenuScene_sim(size: view!.bounds.size)
                    menuScene.scaleMode = .aspectFill
                    menuScene.gameVC = gameVC
                    self.view?.presentScene(menuScene, transition: SKTransition.flipHorizontal(withDuration: 1))
                }
                
                /* if atPoint(location).name == "PauseButton" {
                    if isGamePaused == false {
                        self.isPaused = true
                        gameState = .touchToBegin
                        isGamePaused = true
                    } else {
                        isGamePaused = false
                        self.isPaused = false
                    }
                } */
            
            
 
        if gameState == .tapping {
            
            for i in 0..<buttonList.count {
                if atPoint(location).name == buttonList[i].name {

                    let alphaAction = SKAction.run {
                        self.buttonList[i].alpha = 1
                        }
                    buttonList[i].run(alphaAction, withKey: "alphaAction")
                }
            }
            
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameState == .tapping {
            if let touch = touches.first {
                let location = touch.location(in: self)
                
                if gameState == .tapping || gameState == .touchToBegin || gameState == .gameOver {
                    for i in 0..<buttonList.count {
                        buttonList[i].alpha = 0.2
                    }
                }
                
                if atPoint(location).name == actionSequence[buttonIndex].name {
                    buttonIndex += 1
                    if buttonIndex < actionSequence.count {
                    } else {
                        gameState = .touchToBegin
                        actionButton.text = "Correct!"
                        actionButton.fontColor = .green
                        let wait = SKAction.wait(forDuration: 0.75)
                        let run = SKAction.run {
                            self.actionButton.fontColor = .black
                            self.actionButton.text = "Play Sequence"
                            self.score += 1
                        }
                        self.run(SKAction.sequence([wait, run]))
                    }
                } else if atPoint(location).name != actionSequence[buttonIndex].name && (atPoint(location).name == button0.name || atPoint(location).name == button1.name || atPoint(location).name == button2.name || atPoint(location).name == button3.name) {
                    gameOver()
                }
                
                if gameState == .gameOver {
                    if atPoint(location).name == "actionButton" {
                        actionButton.fontColor = .black
                        actionButton.text = "Play Sequence"
                        gameState = .touchToBegin
                    }
                }
            }
        }
        }
    
    func createButtons() {
        button0 = SKSpriteNode(color: .green, size: CGSize(width: self.size.width * 0.45, height: self.size.width * 0.45))
        button0.anchorPoint = CGPoint(x: 1, y: 0)
        button0.position = CGPoint(x: 0, y: 0)
        button0.name = "button0"
        button0.alpha = 0.2
        self.addChild(button0)
        
        button1 = SKSpriteNode(color: .red, size: CGSize(width: self.size.width * 0.45, height: self.size.width * 0.45))
        button1.anchorPoint = CGPoint(x: 0, y: 0)
        button1.position = CGPoint(x: 0, y: 0)
        button1.name = "button1"
        button1.alpha = 0.2
        
        self.addChild(button1)
        
        button2 = SKSpriteNode(color: .yellow, size: CGSize(width: self.size.width * 0.45, height: self.size.width * 0.45))
        button2.anchorPoint = CGPoint(x: 1, y: 1)

        button2.position = CGPoint(x: 0, y: 0)
        button2.name = "button2"
        button2.alpha = 0.2
        self.addChild(button2)
        
        button3 = SKSpriteNode(color: .blue, size: CGSize(width: self.size.width * 0.45, height: self.size.width * 0.45))
        button3.anchorPoint = CGPoint(x: 0, y: 1)

        button3.position = CGPoint(x: 0, y: 0)
        button3.alpha = 0.2
        self.addChild(button3)
        button3.name = "button3"
        buttonList = [button0, button1, button2, button3]
    }
    
    func addButton() {
        actionButton.text = "Play Sequence"
        actionButton.fontSize = 30
        actionButton.fontColor = .black
        actionButton.position = CGPoint(x: 0, y: button3.position.y - button3.size.height - (actionButton.frame.size.height * 2))
        actionButton.name = "actionButton"
        self.addChild(actionButton)
    }
    
   /* func addPauseButton() {
        let pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "PauseButtonBlack"))
        pauseButton.name = "PauseButton"
        pauseButton.size.width = frame.size.width/10
        pauseButton.size.height = pauseButton.size.width
        pauseButton.position = CGPoint(x: frame.maxX - pauseButton.size.width/2, y: frame.maxY - pauseButton.size.height/2 - 20)
        pauseButton.zPosition = 6
        addChild(pauseButton)
        
    } */
    
    func addScoreLabel() {
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .black
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: button0.position.y + button0.size.height + (scoreLabel.frame.height * 2))
        addChild(scoreLabel)
    }
    
    func animateButtons() {
        let num = Int(randomBetweenNumbers(firstNum: 0, secondNum: 4))
        buttonSequence.append(num)
        var counter = 0
        for i in 0..<buttonSequence.count {
            counter += 1
        let activeButton = buttonList[buttonSequence[i]]
        
        let initialWait = SKAction.wait(forDuration: TimeInterval(0.5))

        
        let iWait = SKAction.wait(forDuration: TimeInterval(1 * CGFloat(i)))
        
        let alphaAction = SKAction.run {
            activeButton.alpha = 1
        }
        alphaAction.timingMode = .easeIn

        let waitAction = SKAction.wait(forDuration: TimeInterval(0.5))
        
        let alphaBack = SKAction.run {
            activeButton.alpha = 0.2
            }
            alphaBack.timingMode = .easeOut
            
            let finalAction = SKAction.run {
                if counter == self.buttonSequence.count {
                self.gameState = .tapping
                self.actionButton.fontColor = .gray
                self.actionButton.text = "Repeat Sequence"
                self.isUserInteractionEnabled = true
                }
            }
        
            actionSequence.append(activeButton)
            actionSequence[i].run(SKAction.sequence([initialWait, iWait, alphaAction, waitAction, alphaBack]))
            
            let finalWait = SKAction.wait(forDuration: TimeInterval(CGFloat(buttonSequence.count)))
            
            self.run(SKAction.sequence([SKAction.wait(forDuration: 0.25), finalWait, waitAction, finalAction]))
        }
        
    }
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func gameOver() {
        gameState = .gameOver
        actionButton.fontColor = .red
        actionButton.text = "Game Over!"
        
        UserDefaults.standard.set(score, forKey: "RecentScore_sim")
        if score > UserDefaults.standard.integer(forKey: "HighScore_sim") {
            UserDefaults.standard.set(score, forKey: "HighScore_sim")
        }
        let wait = SKAction.wait(forDuration: 2.0)
        let run = SKAction.run {
            let menuScene = MenuScene_sim(size: self.view!.bounds.size)
            menuScene.scaleMode = .aspectFill
            menuScene.gameVC = self.gameVC

            self.view!.presentScene(menuScene)
        }
        self.run(SKAction.sequence([wait, run]))
        //Need to go back to main & add high score / recent score. dont need to reset stuff.
    }
    
    func addBackButton() {
        let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButtonBlack"))
        backButton.name = "BackButton"
        backButton.size.width = frame.size.width/10
        backButton.size.height = backButton.size.width
        backButton.position = CGPoint(x: frame.minX + backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 20)
        backButton.zPosition = 6
        
        
        addChild(backButton)
        backButton.color = .white
        backButton.colorBlendFactor = 1.0
    }
    
}*/

