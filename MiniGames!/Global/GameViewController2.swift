//
//  GameViewController.swift
//  BrickBreaker
//
//  Created by Pete Connor on 3/14/18.
//  Copyright © 2018 c0nman. All rights reserved.

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController2: UIViewController, GADBannerViewDelegate {
        
    @IBOutlet weak var bannerView: GADBannerView!
        
    var gameItem: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       let request = GADRequest()
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-9017513021309308/2799201158"
        bannerView.rootViewController = self
        bannerView.load(request)

        if let view = self.view as! SKView? {
            switch gameItem {
        
            case "collide":
                let scene = MenuScene(fileNamed: "MenuScene")
                scene?.scaleMode = .aspectFit
                scene?.gameVC = self
                scene?.gameName = "collide"
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "flash":
                let scene = MenuScene(fileNamed: "MenuScene")
                scene?.scaleMode = .aspectFit
                scene?.gameVC = self
                scene?.gameName = "flash"
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "evade":
                let scene = MenuScene(fileNamed: "MenuScene")
                scene?.scaleMode = .aspectFit
                scene?.gameVC = self
                scene?.gameName = "evade"
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "bounce":
                let scene = MenuScene(fileNamed: "MenuScene")
                scene?.scaleMode = .aspectFit
                scene?.gameVC = self
                scene?.gameName = "bounce"
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "shoot":
                let scene = MenuScene(fileNamed: "MenuScene")
                scene?.scaleMode = .aspectFit
                scene?.gameVC = self
                scene?.gameName = "shoot"
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "match":
                let scene = MenuScene(fileNamed: "MenuScene")
                scene?.scaleMode = .aspectFit
                scene?.gameVC = self
                scene?.gameName = "match"
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            default:
                break
            }
        }
    }
   override var prefersStatusBarHidden: Bool {
    return true
   }
}
