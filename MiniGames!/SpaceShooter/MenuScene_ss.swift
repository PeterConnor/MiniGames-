//
//  MenuScene.swift
//  SpaceShooter
//
//  Created by Pete Connor on 3/6/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import SpriteKit
import GameKit

class MenuScene_ss: SKScene, GKGameCenterControllerDelegate {
    
    var recentScoreLabel = SKLabelNode()

    var leaderButton: SKSpriteNode!
    
    var logo: SKSpriteNode!
    var playLabel = SKLabelNode()

    var starfield: SKEmitterNode!
    
    weak var gameVC: GameViewController2?
    
    var backButton: SKSpriteNode!
    var infoButton: SKSpriteNode!
    
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    override func didMove(to view: SKView) {
                
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.particlePositionRange = CGVector(dx: frame.size.width, dy: frame.size.height)
        
        starfield.position = CGPoint(x: frame.midX, y: self.size.height)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        
        
        
        addLabels()
        addLogo()
        addBackButton()
        addLeaderButton()
        addInfoButton()
        
        /*let thruster = SKEmitterNode(fileNamed: "Thruster")!
        thruster.particleLifetime = 1
        thruster.zPosition = 1
        thruster.particlePositionRange.dx = 30
        thruster.advanceSimulationTime(10)

        
        if UIDevice.current.userInterfaceIdiom == .pad {
            thruster.particlePositionRange.dx = 50
            thruster.particleBirthRate = 600
            thruster.particleLifetime = 1
            thruster.particleLifetimeRange = 2
            thruster.particleSpeed = 35
            thruster.advanceSimulationTime(10)
        }
        //thruster.position.y = player.position.y - player.size.height/2
        //thruster.position.x = player.position.x*/
        logo.anchorPoint = CGPoint(x: 0.5, y: -0.01)
        //thruster.targetNode = logo
       //logo.addChild(thruster)
    
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
        logo = SKSpriteNode(imageNamed: "shuttle")
        logo.size = CGSize(width: frame.size.width/4, height: frame.size.width/3)
        logo.position = CGPoint(x: frame.midX, y: frame.maxY - logo.size.height * 1.5)
        logo.zPosition = 2
        addChild(logo)
    }
    
    func addLabels() {
        playLabel = SKLabelNode(text: "Tap Spaceship to Play!")
        playLabel.fontName = "AvenirNext-Bold"
        playLabel.fontSize = 25.0
        playLabel.fontColor = UIColor.white
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(playLabel)
        animate(label: playLabel)
        
        let highscoreLabel = SKLabelNode(text: "High Score: \(UserDefaults.standard.integer(forKey: "HighScore_ss"))")
        highscoreLabel.fontName = "AvenirNext-Bold"
        highscoreLabel.fontSize = 30.0
        highscoreLabel.fontColor = UIColor.white
        highscoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - highscoreLabel.frame.size.height*3)
        addChild(highscoreLabel)
        
        recentScoreLabel = SKLabelNode(text: "Recent Score: \(UserDefaults.standard.integer(forKey: "RecentScore_ss"))")
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
        let gameScene = GameScene_ss(size: view!.bounds.size)
        gameScene.scaleMode = .aspectFill
        if let touch = touches.first {
            let location = touch.location(in: self)
            if let logo = logo {
                if logo.contains(location) {
                    gameScene.gameVC = gameVC
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
        gcVC.leaderboardIdentifier = "MiniGames! - Space Shooter"
        gameVC?.present(gcVC, animated: true, completion: nil)
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore() {
        let leaderboardID = "MiniGames! - Space Shooter"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(UserDefaults.standard.integer(forKey: "HighScore_ss"))
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
        let myAlert: UIAlertController = UIAlertController(title: "Instructions", message: "Tilt the screen to move the spaceship left or right. Tap the screen to fire torpedoes. Destroy the alien ships before they reach the bottom of the screen!", preferredStyle: .alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        gameVC?.present(myAlert, animated: true, completion: nil)
    }
}
