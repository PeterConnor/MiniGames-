//
//  FileMenuScene_evade.swift
//  MiniGames!
//
//  Created by Pete Connor on 7/2/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
import SpriteKit
import GameKit

class MenuScene: SKScene, GKGameCenterControllerDelegate {
    
    var logo: SKSpriteNode!
    
    weak var gameVC: GameViewController2?
    var gameName: String?
    
    var backButton: SKSpriteNode!
    var helpButton: SKSpriteNode!
    var playButton: SKSpriteNode!
    
    
    
    var leaderButton: SKSpriteNode!
    
    //var recentScoreLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        addLogo()
        addLabelsAndButtons()
        addBackButton()
        addLeaderButton()
    }
    
    func addLogo() {
        logo = SKSpriteNode(imageNamed: "image_" + gameName!)
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
        var score = UserDefaults.standard.integer(forKey: "HighScore_" + gameName!)
        if score > 999 {
            score = 999
        }
        highscoreLabel.position = CGPoint(x: helpButton.position.x, y: helpButton.position.y - helpButtonBlurr.size.height/2 - 25)
        //highscoreLabel.xScale = 0.5
        //highscoreLabel.yScale = 0.5

        addChild(highscoreLabel)
        let highscoreLabelBlurr = SKSpriteNode(imageNamed: "HighScoreRedBlurr")
        //backButtonBlurr.size = CGSize(width: 67.2, height: 115.8)
        highscoreLabel.addChild(highscoreLabelBlurr)
        highscoreLabelBlurr.zPosition = -1
        
        let scoreLabel1 = SKSpriteNode(imageNamed: "num0")
        let scoreLabel2 = SKSpriteNode(imageNamed: "num0")
        let scoreLabel3 = SKSpriteNode(imageNamed: "num0")
        let blurr1 = SKSpriteNode(imageNamed: "BlueNum0")
        let blurr2 = SKSpriteNode(imageNamed: "BlueNum0")
        let blurr3 = SKSpriteNode(imageNamed: "BlueNum0")
        scoreLabel1.position = CGPoint(x: frame.midX - blurr1.size.width/2, y: highscoreLabel.position.y - highscoreLabelBlurr.size.height/2 - 25)
        scoreLabel2.position = CGPoint(x: frame.midX, y: highscoreLabel.position.y - highscoreLabelBlurr.size.height/2 - 25)
        scoreLabel3.position = CGPoint(x: frame.midX + blurr3.size.width/2, y: highscoreLabel.position.y - highscoreLabelBlurr.size.height/2 - 25)
        addChild(scoreLabel1)
        addChild(scoreLabel2)
        addChild(scoreLabel3)
        scoreLabel1.addChild(blurr1)
        blurr1.zPosition = -1
        scoreLabel2.addChild(blurr2)
        blurr2.zPosition = -1
        scoreLabel3.addChild(blurr3)
        blurr3.zPosition = -1

        
        let stringFromNum = String(score)
        var numList = [String]()
        
        for char in stringFromNum {
            numList.append(String(char))
        }
        
        switch numList.count {
            
        case 1:
            //scoreLabel3.texture = SKTexture(imageNamed: "num" + numList[0])
            //blurr3.texture = SKTexture(imageNamed: "BlueNum" + numList[0])
            scoreLabel3.texture = SKTexture(imageNamed: "num" + numList[0])
            blurr3.texture = SKTexture(imageNamed: "BlueNum" + numList[0])
        case 2:
            scoreLabel3.texture = SKTexture(imageNamed: "num" + numList[1])
            blurr3.texture = SKTexture(imageNamed: "BlueNum" + numList[1])
            
            scoreLabel2.texture = SKTexture(imageNamed: "num" + numList[0])
            blurr2.texture = SKTexture(imageNamed: "BlueNum" + numList[0])
        case 3:
            scoreLabel3.texture = SKTexture(imageNamed: "num" + numList[2])
            blurr3.texture = SKTexture(imageNamed: "BlueNum" + numList[2])
            
            scoreLabel2.texture = SKTexture(imageNamed: "num" + numList[1])
            blurr2.texture = SKTexture(imageNamed: "BlueNum" + numList[1])
            
            scoreLabel1.texture = SKTexture(imageNamed: "num" + numList[0])
            blurr1.texture = SKTexture(imageNamed: "BlueNum" + numList[0])
        default:
            break
        }
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
    
        if let touch = touches.first {
            let location = touch.location(in: self)
            if let playButton = playButton {
                if playButton.contains(location) {
                    switch gameName {
                    case "evade":
                        let gameScene = GameScene_evade(fileNamed: "GameScene_" + gameName!)
                            gameScene!.scaleMode = .aspectFit
                            gameScene!.gameVC = gameVC
                            view!.ignoresSiblingOrder = true
                            view!.presentScene(scene)
                            view!.presentScene(gameScene)
                        
                    case "flash":
                        let gameScene = GameScene_flash(fileNamed: "GameScene_" + gameName!)
                        gameScene!.scaleMode = .aspectFit
                        gameScene!.gameVC = gameVC
                        view!.ignoresSiblingOrder = true
                        view!.presentScene(scene)
                        view!.presentScene(gameScene)
                    case "collide":
                        let gameScene = GameScene_collide(fileNamed: "GameScene_" + gameName!)
                        gameScene!.scaleMode = .aspectFit
                        gameScene!.gameVC = gameVC
                        view!.ignoresSiblingOrder = true
                        view!.presentScene(scene)
                        view!.presentScene(gameScene)
                    case "bounce":
                        let gameScene = GameScene_bounce(fileNamed: "GameScene_" + gameName!)
                        gameScene!.scaleMode = .aspectFit
                        gameScene!.gameVC = gameVC
                        view!.ignoresSiblingOrder = true
                        view!.presentScene(scene)
                        view!.presentScene(gameScene)
                    case "shoot":
                        let gameScene = GameScene_shoot(fileNamed: "GameScene_" + gameName!)
                        gameScene!.scaleMode = .aspectFit
                        gameScene!.gameVC = gameVC
                        view!.ignoresSiblingOrder = true
                        view!.presentScene(scene)
                        view!.presentScene(gameScene)
                    default:
                        break
                    }
                    if UserDefaults.standard.integer(forKey: "HighScore_" + gameName!) < 5 {
                        showAlert()
                    }
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
        
        gcVC.leaderboardIdentifier = "MiniGames! - " + "\(gameName!.capitalized)"
        gameVC?.present(gcVC, animated: true, completion: nil)
    
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func submitScore() {
        let leaderboardID = "MiniGames! - " + "\(gameName!.capitalized)"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(UserDefaults.standard.integer(forKey: "HighScore_" + gameName!))
        //let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        GKScore.report([sScore]) { (error: Error!) -> Void in
            if error != nil {
                //print(error.localizedDescription)
            } else {
                //print("Score Submitted")

            }
        }
    }
    
    func showAlert() {
        var myAlert = UIAlertController()
        switch gameName {
        case "evade":
            myAlert = UIAlertController(title: "Instructions", message: "Press the left and right side of the screen to guide the green disc through the obstacles. The more obstacles you pass, the more points you earn! (Pro Tip: Hold the device with both hands and press down with your thumbs)", preferredStyle: .alert)
        case "flash":
            myAlert = UIAlertController(title: "Instructions", message: "Tap 'Play' to begin the flashing sequence. Memorize the location and order of flashing discs. Earn points by repeating back the ever-growing sequence correctly!" , preferredStyle: .alert)
        case "collide":
            myAlert = UIAlertController(title: "Instructions", message: "Tap once to move the blue disc. Once the blue disc overlaps the red disc, tap again. Repeat this action to earn points! (Tap the bottom of the screen. Not the actual discs!)", preferredStyle: .alert)
        case "bounce":
            myAlert = UIAlertController(title: "Instructions", message: "Tap once to launch the green disc. Tilt the phone to the left or right to make the green disc bounce off of the obstacles. Climb as high as you can to earn points! ", preferredStyle: .alert)
        case "shoot":
            myAlert = UIAlertController(title: "Instructions", message: "Tilt the phone to the left or right to move the green disc. Tap the screen to shoot the approaching enemies. Don't let any of the enemies get passed you!", preferredStyle: .alert)
        default:
            break
        }
        
        myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        gameVC?.present(myAlert, animated: true, completion: nil)
    }
}
