//
//  MenuScene_gs.swift
//  MiniGames!
//
//  Created by Pete Connor on 6/13/18.
//  Copyright © 2018 c0nman. All rights reserved.
//

import SpriteKit
import GameKit

class MenuScene_gs: SKScene, GKGameCenterControllerDelegate {
    
    var logo = SKSpriteNode()
    
    weak var gameVC: GameViewController2?
    
    var leaderButton = SKSpriteNode()
    
    var backButton = SKSpriteNode()
    var infoButton = SKSpriteNode()
    
    var recentScoreLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 102/255, green: 178/255, blue: 255/255, alpha: 1)
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
        infoButton.position = CGPoint(x: frame.maxX - infoButton.size.width/2, y: frame.maxY - infoButton.size.height/2 - 40)
        infoButton.zPosition = 6
        
        addChild(infoButton)
    }
    

    
    func addLogo() {
        logo = SKSpriteNode(imageNamed: "Apple2")
        logo.size.width = frame.size.width/4
        logo.size.height = logo.size.width
        logo.position = CGPoint(x: frame.midX, y: frame.midY + frame.size.height/4)
        logo.zPosition = 1
        addChild(logo)
        
    }
    
    func addLabels() {
        let playLabel = SKLabelNode(text: "Tap Apple to Play!")
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontSize = 30.0
        playLabel.fontColor = UIColor.white
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        playLabel.zPosition = 1
        addChild(playLabel)
        animate(label: playLabel)
        
        
        let highscoreLabel = SKLabelNode(text: "High Score: \(UserDefaults.standard.integer(forKey: "HighScore_gs"))")
        highscoreLabel.fontName = "AvenirNext-Bold"
        highscoreLabel.fontSize = 30.0
        highscoreLabel.fontColor = UIColor.white
        highscoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - highscoreLabel.frame.size.height*4)
        highscoreLabel.zPosition = 1
        addChild(highscoreLabel)
        
        recentScoreLabel = SKLabelNode(text: "Recent Score: \(UserDefaults.standard.integer(forKey: "RecentScore_gs"))")
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
        let gameplay = GameScene_gs(fileNamed: "GameScene_gs")
        if let touch = touches.first {
            let location = touch.location(in: self)
                if logo.contains(location) {
                    gameplay?.scaleMode = .aspectFit
                    gameplay!.gameVC = gameVC
                    self.view?.presentScene(gameplay!, transition: SKTransition.flipHorizontal(withDuration: 1))
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
        leaderButton.name = "LeaderButton"
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
        gcVC.leaderboardIdentifier = "MiniGames! - Granny Smith"
        gameVC?.present(gcVC, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore() {
        let leaderboardID = "MiniGames! - Granny Smith"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(UserDefaults.standard.integer(forKey: "HighScore_gs"))
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
        let myAlert: UIAlertController = UIAlertController(title: "Instructions", message: "Tap on the left or right of the screen to move Granny Smith in the corresponding direction. Collect the red and green apples to earn points. Avoid those rotten apples!", preferredStyle: .alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        gameVC?.present(myAlert, animated: true, completion: nil)
    }
    
}
