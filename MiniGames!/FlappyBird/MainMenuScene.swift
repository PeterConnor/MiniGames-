//
//  MainMenuScene.swift
//  MiniGames!
//
//  Created by Pete Connor on 5/6/18.
//  Copyright © 2018 c0nman. All rights reserved.
//

import SpriteKit
import GameKit

class MainMenuScene: SKScene, GKGameCenterControllerDelegate {
    
    var logo: SKSpriteNode!
    
    var leaderButton: SKSpriteNode!
    
    weak var gameVC: GameViewController2?
    
    var backButton: SKSpriteNode!
    var infoButton: SKSpriteNode!
    
    var recentScoreLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 42/255, green: 212/255, blue: 255/255, alpha: 1.0)
        addLogo()
        addLabels()
        //addBackground()
        addBackButton()
        addLeaderButton()
        addInfoButton()
    }
    
    func addBackButton() {
        backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        backButton.size.width = frame.size.width/10
        backButton.size.height = backButton.size.width
        backButton.position = CGPoint(x: frame.minX + backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 40)
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
        infoButton.position = CGPoint(x: frame.maxX - backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 40)
        infoButton.zPosition = 6
        
        addChild(infoButton)
    }
    
    func addBackground() {
        let bg = SKSpriteNode(imageNamed: "BG Day")
        bg.name = "BG"
        bg.zPosition = 0
        bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        bg.position = CGPoint(x: 0, y: 0)
        self.addChild(bg)
    }
    
    func addLogo() {
        logo = SKSpriteNode(imageNamed: "Blue 1")
        logo.size.width = frame.size.width/4
        logo.size.height = logo.size.width * 0.75
        logo.position = CGPoint(x: frame.midX, y: frame.midY + frame.size.height/4)
        logo.zPosition = 1
        addChild(logo)
    
    }
    
    func addLabels() {
        let playLabel = SKLabelNode(text: "Tap Bee to Play!")
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontSize = 30.0
        playLabel.fontColor = UIColor.white
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        playLabel.zPosition = 1
        addChild(playLabel)
        animate(label: playLabel)
        
        let highscoreLabel = SKLabelNode(text: "High Score: \(UserDefaults.standard.integer(forKey: "HighScore_fb"))")
        highscoreLabel.fontName = "AvenirNext-Bold"
        highscoreLabel.fontSize = 30.0
        highscoreLabel.fontColor = UIColor.white
        highscoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - highscoreLabel.frame.size.height*3)
        highscoreLabel.zPosition = 1
        addChild(highscoreLabel)
        
        recentScoreLabel = SKLabelNode(text: "Recent Score: \(UserDefaults.standard.integer(forKey: "RecentScore_fb"))")
        recentScoreLabel.fontName = "AvenirNext-Bold"
        recentScoreLabel.fontSize = 30.0
        recentScoreLabel.fontColor = UIColor.white
        recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height*2)
        recentScoreLabel.zPosition = 1
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
        let gameplay = GameplayScene(fileNamed: "GameplayScene")
        if let touch = touches.first {
            let location = touch.location(in: self)
            if let logo = logo {
                if logo.contains(location) {
                    gameplay?.scaleMode = .aspectFit
                    gameplay!.gameVC = gameVC

                    self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: 1))

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
        gcVC.leaderboardIdentifier = "MiniGames! - Buzzy Bee"
        gameVC?.present(gcVC, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore() {
        let leaderboardID = "MiniGames! - Buzzy Bee"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(UserDefaults.standard.integer(forKey: "HighScore_fb"))
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
        let myAlert: UIAlertController = UIAlertController(title: "Instructions", message: "Tap the screen repeatedly to make Buzzy fly. Stay in between the cacti and avoid the ground to earn points", preferredStyle: .alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        gameVC?.present(myAlert, animated: true, completion: nil)
    }
}
