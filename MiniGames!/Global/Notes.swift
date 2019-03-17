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
If your app is published to the App Store, remember to come back to link your app. - Admob
---

rate crashes with no service
put real unit id in

***Eventually***
make flash objects 1 image, so taps on blur register
change support url. currently, twitter.
change all blurrs to blur
console message
android
iPad
feedback/email?
premium?
add sounds (add global singleton bool for mute)
landing page
product hunt
add videos to app store
make ios 10
 */

/*Skeleton
 
 import SpriteKit
 
 class GameScene_bounce: SKScene, SKPhysicsContactDelegate {
 
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
 blurr2.texture = numAtlas.textureNamed("BlueNum\(tens)")
 scoreLabel1.texture = SKTexture(imageNamed: "num\(hundreds)")
 blurr1.texture = numAtlas.textureNamed("BlueNum\(hundreds)")
 
 }
 
 if score % 10 == 0 && score % 100 != 0 {
 ones = 0
 tens += 1
 scoreLabel2.texture = SKTexture(imageNamed: "num\(tens)")
 blurr2.texture = numAtlas.textureNamed("BlueNum\(tens)")
 
 
 }
 scoreLabel3.texture = SKTexture(imageNamed: "num\(ones)")
 blurr3.texture = numAtlas.textureNamed("BlueNum\(ones)")
 
 if score >= 999 {
 scoreLabel1.texture = SKTexture(imageNamed: "num9")
 blurr1.texture = numAtlas.textureNamed("BlueNum9")
 
 scoreLabel2.texture = SKTexture(imageNamed: "num9")
 blurr2.texture = numAtlas.textureNamed("BlueNum9")
 
 scoreLabel3.texture = SKTexture(imageNamed: "num9")
 blurr3.texture = numAtlas.textureNamed("BlueNum9")
 }
 }
 }
 
 
 override func didMove(to view: SKView) {
 
 numAtlas.preload {
 }
 self.physicsWorld.contactDelegate = self
 
 NotificationCenter.default.addObserver(self, selector: #selector(GameScene_bounce.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
 
 addPauseButton()
 addBackButton()
 addScoreLabels()
 }
 
 
 
 @objc func pauseGame() {
 self.isPaused = true
 isGamePaused = true
 pauseButton.texture = SKTexture(imageNamed: "PlayButton")
 pauseButtonBlurr.texture = SKTexture(imageNamed: "GreenPlayButtonBlurr")
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
 
 pauseButtonBlurr = SKSpriteNode(imageNamed: "GreenPauseButtonBlurr")
 //pauseButtonBlurr.size = CGSize(width: 72.4, height: 104.7)
 pauseButton.addChild(pauseButtonBlurr)
 pauseButtonBlurr.zPosition = -1
 
 pauseButton.position = CGPoint(x: 750 - pauseButtonBlurr.size.width/2 - 25, y: 1334 - pauseButtonBlurr.size.height/2 - 25)
 
 }
 
 func addBackButton() {
 let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
 backButton.name = "BackButton"
 //backButton.size = CGSize(width: 32.3, height: 75)
 backButton.zPosition = 6
 addChild(backButton)
 
 let backButtonBlurr = SKSpriteNode(imageNamed: "RedBackButtonBlurr")
 //ZbackButtonBlurr.size = CGSize(width: 67.2, height: 115.8)
 backButton.addChild(backButtonBlurr)
 backButtonBlurr.zPosition = -1
 
 backButton.position = CGPoint(x: 0 + backButtonBlurr.size.width/2 + 25, y: 1334 - backButtonBlurr.size.height/2 - 25)
 
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
 
 override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
 if started && !isPaused {
 //canMove = true - from evade
 }
 for touch in touches {
 
 let location = touch.location(in: self)
 
 if atPoint(location).name == "BackButton" {
 let menuScene = MenuScene(fileNamed: "MenuScene")
 menuScene?.scaleMode = .aspectFit
 menuScene?.gameName = "bounce"
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
 pauseButtonBlurr.texture = SKTexture(imageNamed: "GreenPauseButtonBlurr")
 self.speed = 1.0
 self.physicsWorld.speed = 1.0
 }
 }
 
 
 }
 }
 
 }

 
 adding new game:
 add image
 add folder, swift file, skscene
 add case to gameviewcontroller2
 add to singleton
 change collection view width & height #'s
 add case to menuscene
 make sure sks file anchorpoint is 0,0
 add skeleton

 }*/



