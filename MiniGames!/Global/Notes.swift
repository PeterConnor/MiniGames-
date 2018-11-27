//
//  Notes.swift
//  MiniGames!
//
//  Created by Pete Connor on 5/6/18.
//  Copyright © 2018 c0nman. All rights reserved.
//

/*
 
 **Admob**
 App ID: ca-app-pub-9017513021309308~3266105011
 Ad Unit ID: ca-app-pub-9017513021309308/2799201158
 Test Unit ID: ca-app-pub-3940256099942544/2934735716
 
****Macro****
Need to add actual app store url to share button
Add right admob info
If your app is published to the App Store, remember to come back to link your app. - Admob
 replace test admob
 Menuscenes - Tap to play change to cool play button (thin lines with glow). like so: https://www.shutterstock.com/image-vector/play-button-blue-glowing-neon-ui-692614963
 Make sure menus don't look like old ones for spam
 shooting stars game. like duck hunt across the screen.
---
*To Do*
*split*
Add score
Make progressively harder
 
*pop*
make gvvectors same length. progressively harder = decrease mass.
 
*sim*
simon says, but the lights disappear!
 
***Eventually***
console messages
android
iPad
feedback/email?
premium?
add sounds (add global singleton bool for mute)
 */

/*Skeleton
 
import SpriteKit

class GameScene_split: SKScene, SKPhysicsContactDelegate {
    
    weak var gameVC: GameViewController2?
    
    var isGamePaused = false
    var pauseButton = SKSpriteNode()
    
    var scoreLabel = SKLabelNode(fontNamed: "avenirNext-Bold")
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_split.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
 
    self.physicsWorld.contactDelegate = self

        
        addBackButton()
        addPauseButton()
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
    
    @objc func pauseGame() {
        //timeCheck = 1
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButtonWhite")
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    func gameOver() {
        
        UserDefaults.standard.set(score, forKey: "RecentScore_split")
        if score > UserDefaults.standard.integer(forKey: "HighScore_split") {
            UserDefaults.standard.set(score, forKey: "HighScore_split")
        }
        
        if let view = self.view as SKView? {
            let scene = MenuScene_split(size: view.bounds.size)
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
}*/



