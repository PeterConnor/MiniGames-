//
//  FileMenuScene_split.swift
//  MiniGames!
//
//  Created by Pete Connor on 7/2/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
import SpriteKit
import GameKit

class MenuScene_split: SKScene, GKGameCenterControllerDelegate {
    
    var logo: SKSpriteNode!
    
    weak var gameVC: GameViewController2?
    
    var backButton: SKSpriteNode!
    var helpButton: SKSpriteNode!
    var playButton: SKSpriteNode!
    
    var leaderButton: SKSpriteNode!
    
    var recentScoreLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        addLogo()
        addLabelsAndButtons()
        addBackButton()
        addLeaderButton()
        print(self.size)
        
    }
    
    func addLogo() {
        logo = SKSpriteNode(imageNamed: "image_split")
        logo.size = CGSize(width: 500, height: 500)
        logo.position = CGPoint(x: frame.midX, y: frame.maxY - logo.size.height/2)
        addChild(logo)

        
    }
    
    func addBackButton() {
        backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        backButton.zPosition = 6
        addChild(backButton)
        
        let backButtonBlurr = SKSpriteNode(imageNamed: "GreenBackButtonBlurr")
        //backButtonBlurr.size = CGSize(width: 67.2, height: 115.8)
        backButton.addChild(backButtonBlurr)
        backButtonBlurr.zPosition = -1
        
        backButton.position = CGPoint(x: 0 + backButtonBlurr.size.width/2 + 25, y: 1334 - backButtonBlurr.size.height/2 - 25)
        
    }
    
   
    
    func addLabelsAndButtons() {
        playButton = SKSpriteNode(imageNamed: "PlayWhite")
        let playButtonBlurr = SKSpriteNode(imageNamed: "PlayGreenBlurr")
        //backButtonBlurr.size = CGSize(width: 67.2, height: 115.8)
        playButton.addChild(playButtonBlurr)
        //playButton.xScale = 0.5
        //playButton.yScale = 1
        playButtonBlurr.zPosition = -1
        
        playButton.position = CGPoint(x: frame.midX, y: logo.position.y - logo.size.height/2 - playButtonBlurr.size.height/2)
        addChild(playButton)
        //animate(label: playButton)
        
        helpButton = SKSpriteNode(imageNamed: "HelpWhite")
        helpButton.name = "helpButton"
        addChild(helpButton)
        let helpButtonBlurr = SKSpriteNode(imageNamed: "HelpBlueBlurr")
        //backButtonBlurr.size = CGSize(width: 67.2, height: 115.8)
        helpButton.addChild(helpButtonBlurr)
        //helpButton.xScale = 0.5
        //helpButton.yScale = 0.5
        helpButtonBlurr.zPosition = -1
        
        helpButton.position = CGPoint(x: frame.midX, y: playButton.position.y - playButtonBlurr.size.height/2 - 25)
        
        
        let highscoreLabel = SKSpriteNode(imageNamed: "HighScoreWhite")
        let score = UserDefaults.standard.integer(forKey: "HighScore_split")
        highscoreLabel.position = CGPoint(x: helpButton.position.x, y: helpButton.position.y - helpButtonBlurr.size.height/2 - 25)
        //highscoreLabel.xScale = 0.5
        //highscoreLabel.yScale = 0.5

        addChild(highscoreLabel)
        let highscoreLabelBlurr = SKSpriteNode(imageNamed: "HighScoreRedBlurr")
        //backButtonBlurr.size = CGSize(width: 67.2, height: 115.8)
        highscoreLabel.addChild(highscoreLabelBlurr)
        highscoreLabelBlurr.zPosition = -1
        
        recentScoreLabel = SKLabelNode(text: "Recent Score: \(UserDefaults.standard.integer(forKey: "RecentScore_split"))")
        recentScoreLabel.fontName = "AvenirNext-Bold"
        recentScoreLabel.fontSize = 30.0
        recentScoreLabel.fontColor = UIColor.red
        recentScoreLabel.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - recentScoreLabel.frame.size.height*2)
        //addChild(recentScoreLabel)
    }
    
    func animate(label: SKSpriteNode) {
        //let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        //let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        
        //let sequence = SKAction.sequence([fadeOut, fadeIn])
        let sequence2 = SKAction.sequence([scaleUp, scaleDown])
        label.run(SKAction.repeatForever(sequence2))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene_split(fileNamed: "GameScene_split")
        if let touch = touches.first {
            let location = touch.location(in: self)
            if let playButton = playButton {
                if playButton.contains(location) {
                    gameScene!.scaleMode = .aspectFit
                    gameScene!.gameVC = gameVC
                    view!.ignoresSiblingOrder = true
                    view!.presentScene(scene)
                    view!.presentScene(gameScene)
                }
            }
            if backButton.contains(location) {
                gameVC?.dismiss(animated: true, completion: nil)
            }
            if leaderButton.contains(location) {
                showLeader()
            }
            
            if helpButton.contains(location) {
                showAlert()
            }
            
        }
    }
    
    func addLeaderButton() {
        leaderButton = SKSpriteNode(texture: SKTexture(imageNamed: "LeaderButton"))
        leaderButton.name = "BackButton"
        leaderButton.size.width = frame.size.width/15
        leaderButton.size.height = leaderButton.size.width
        leaderButton.position = CGPoint(x: frame.midX, y: 0 + leaderButton.size.height
            + 100)
        leaderButton.xScale = 2
        leaderButton.yScale = 2
        leaderButton.zPosition = 6
        
        addChild(leaderButton)
    }
    
    func showLeader() {
        
        submitScore()
        
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "MiniGames! - Banana Split"
        gameVC?.present(gcVC, animated: true, completion: nil)
    
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore() {
        let leaderboardID = "MiniGames! - Banana Split"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(UserDefaults.standard.integer(forKey: "HighScore_split"))
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
        let myAlert: UIAlertController = UIAlertController(title: "Instructions", message: "Split the bananas by applying pressure to the screen with your finger. Guide the bananas through the obstacles to earn points!", preferredStyle: .alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        gameVC?.present(myAlert, animated: true, completion: nil)
    }
    
}
