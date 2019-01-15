//
//  MenuScene.swift
//  Collide
//
//  Created by Pete Connor on 3/28/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import Foundation
import SpriteKit
import GameKit

class MenuScene_collide: SKScene, GKGameCenterControllerDelegate {
    
    var recentScoreLabel = SKLabelNode()

    var leaderButton: SKSpriteNode!
    
    var playLabel: SKLabelNode!
    var logo: SKSpriteNode!
    
    weak var gameVC: GameViewController2?

    var backButton: SKSpriteNode!
    var infoButton: SKSpriteNode!

    
    override func didMove(to view: SKView) {
        addLabels()
        addLogo()
        addBackButton()
        backgroundColor = .black
        addLeaderButton()
        addInfoButton()
    }
    
    func addBackButton() {
        backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        backButton.size.width = frame.size.width/10
        backButton.size.height = backButton.size.width
        backButton.position = CGPoint(x: frame.minX + backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 20)
        backButton.zPosition = 6
        
        addChild(backButton)
        backButton.color = .white
        backButton.colorBlendFactor = 1.0
    }
    
    func addInfoButton() {
        infoButton = SKSpriteNode(texture: SKTexture(imageNamed: "InfoButtonWhite"))
        infoButton.name = "InfoButton"
        infoButton.size.width = frame.size.width/10
        infoButton.size.height = infoButton.size.width
        infoButton.position = CGPoint(x: frame.maxX - backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 20)
        infoButton.zPosition = 6
        
        addChild(infoButton)
    }

    func addLogo() {
        logo = SKSpriteNode(imageNamed: "image_collide")
        logo.size = CGSize(width: frame.size.width/2, height: frame.size.width/2)
        logo.position = CGPoint(x: frame.midX, y: frame.midY + frame.size.height/4)
        addChild(logo)
        
    }
    


func addLabels() {
    playLabel = SKLabelNode(text: "Tap Logo to Play!")
    playLabel.fontName = "AvenirNext-Bold"
    playLabel.fontSize = 30.0
    playLabel.fontColor = UIColor.white
    playLabel.position = CGPoint(x: frame.midX, y: frame.midY)
    addChild(playLabel)
    animate(label: playLabel)
    
    let highscoreLabel = SKLabelNode(text: "High Score: \(UserDefaults.standard.integer(forKey: "HighScore_collide"))")
    highscoreLabel.fontName = "AvenirNext-Bold"
    highscoreLabel.fontSize = 30.0
    highscoreLabel.fontColor = UIColor.white
    highscoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - highscoreLabel.frame.size.height*3)
    addChild(highscoreLabel)
    
    recentScoreLabel = SKLabelNode(text: "Recent Score: \(UserDefaults.standard.integer(forKey: "RecentScore_collide"))")
    recentScoreLabel.fontName = "AvenirNext-Bold"
    recentScoreLabel.fontSize = 30.0
    recentScoreLabel.fontColor = UIColor.white
    recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height*2)
    addChild(recentScoreLabel)
}

func animate(label: SKLabelNode) {
    //let fadeOut = SKAction.fadeOut(withDuration: 0.5)
    //let fadeIn = SKAction.fadeIn(withDuration: 0.5)
    
    let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
    let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
    
    //let sequence = SKAction.sequence([fadeOut, fadeIn])
    let sequence2 = SKAction.sequence([scaleUp, scaleDown])
    label.run(SKAction.repeatForever(sequence2))
    
}

override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    let gameScene = GameScene_collide(fileNamed: "GameScene_collide")
    if let touch = touches.first {
        let location = touch.location(in: self)
        if let logo = logo {
            if logo.contains(location) {
                gameScene?.scaleMode = .aspectFit
                gameScene?.backgroundColor = .black
                gameScene?.gameVC = gameVC
                view!.presentScene(gameScene)
            }
        }
        if backButton.contains(location) {
            gameVC?.dismiss(animated: true, completion: nil)
        }
        
        if leaderButton.contains(location) {
            showLeader()
        }
        
        if infoButton.contains(location) {
            showAlert()
        }
    }
}
    
    func addLeaderButton() {
        leaderButton = SKSpriteNode(texture: SKTexture(imageNamed: "LeaderButton"))
        leaderButton.name = "BackButton"
        leaderButton.size.width = frame.size.width/15
        leaderButton.size.height = leaderButton.size.width
        leaderButton.position = CGPoint(x: frame.midX, y: recentScoreLabel.frame.minY - leaderButton.size.height * 2)
        leaderButton.size = CGSize(width: leaderButton.size.height*2.2, height: frame.size.width/10)
        leaderButton.zPosition = 6
        
        addChild(leaderButton)
    }
    
    func showLeader() {
        
        submitScore()
        
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "MiniGames! - Crack The Safe"
        gameVC?.present(gcVC, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore() {
        let leaderboardID = "MiniGames! - Crack The Safe"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(UserDefaults.standard.integer(forKey: "HighScore_collide"))
        //let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        GKScore.report([sScore]) { (error: Error!) -> Void in
            if error != nil {
                print(error.localizedDescription)
            } else {
                print("Score Submitted")
                
            }
        }
        
    }
    
    func showAlert() {
        let myAlert: UIAlertController = UIAlertController(title: "Instructions", message: "Tap the screen and the red bar will start moving. Once the red bar overlaps the white circle, tap the screen again. Repeat this action to earn points!", preferredStyle: .alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        gameVC?.present(myAlert, animated: true, completion: nil)
    }
}
