//
//  GameScene.swift
//  ButtonPush
//
//  Created by Pete Connor on 2/27/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import SpriteKit
import GameplayKit

enum GameState_bt {
    case ready
    case playing
    case gameover
}

class GameScene_bt: SKScene {
    
    
    weak var gameVC: GameViewController2?
    
    var score = 0
    var button: SKSpriteNode!
    var scoreLabel = SKLabelNode(text: "SCORE: 0")
    var timeLabel = SKLabelNode(text: "TIME: 10 Seconds")
    var gameState = GameState_bt.ready
    var remainingTime: Int = 10 {
        didSet {
            timeLabel.text = "TIME: \(remainingTime) Seconds"
            if remainingTime == 0 {
                timeLabel.removeAllActions()
                gameOver()
            }
            
            //then do skaction wait 1 sec to update timelabel. When to start tho? countdown?
            //make button a texture like ball in colorswitch
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 102/255, green: 178/255, blue: 255/255, alpha: 1)
        addButton()
        addLabels()
        addBackButton()
    }
    
    func addButton() {
        button = SKSpriteNode(color: .red, size: CGSize(width: frame.size.width/2, height: frame.size.width/2))
        button.texture = SKTexture(imageNamed: "ButtonUp")
        button?.position = CGPoint(x: frame.midX, y: frame.midY)
        button?.zPosition = 1
        addChild(button!)
    }
    
    func addLabels() {
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + button.size.height)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        timeLabel.fontName = "AvenirNext-Bold"
        timeLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30
        timeLabel.fontColor = UIColor.white
        timeLabel.position = CGPoint(x: frame.midX, y: frame.midY - button.size.height)
        timeLabel.zPosition = 2
        addChild(timeLabel)
        
    }
    
    
    
    func timerAction() {
        if score == 0 {
            let waitAction = SKAction.wait(forDuration: 1.0)
            let timerAction = SKAction.run {
                self.remainingTime -= 1
            }
            let repeatAction = SKAction.repeatForever(SKAction.sequence([waitAction, timerAction]))
            timeLabel.run(repeatAction)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if atPoint(location).name == "BackButton" {
                
                let menuScene = MenuScene_bt(size: view!.bounds.size)
                menuScene.scaleMode = .aspectFill
                menuScene.gameVC = gameVC
                self.view?.presentScene(menuScene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1))
            }
            
            
        }
            if let touch = touches.first {
                let location = touch.location(in: self)
                if button != nil  {
                    if button.contains(location) {
                        if remainingTime > 0 {
                            gameState = .playing
                            timerAction()
                            button.texture = SKTexture(imageNamed: "ButtonDown")
                            score += 1
                            scoreLabel.text = "SCORE: \(score)"
                        } else {
                        }
                    }
                }
            }
        }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        button.texture = SKTexture(imageNamed: "ButtonUp")
    }
    
    func gameOver() {
            UserDefaults.standard.set(score, forKey: "RecentScore_bt")
            if score > UserDefaults.standard.integer(forKey: "HighScore_bt") {
                UserDefaults.standard.set(score, forKey: "HighScore_bt")
            }
        self.run(SKAction.wait(forDuration: 2.0)) {
            let menuScene = MenuScene_bt(size: self.view!.bounds.size)
            menuScene.scaleMode = .aspectFill
            menuScene.gameVC = self.gameVC
            self.view!.presentScene(menuScene)
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
    }

