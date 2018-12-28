//
//  GameViewController.swift
//  BrickBreaker
//
//  Created by Pete Connor on 3/14/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//
import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds


class GameViewController2: UIViewController, GADBannerViewDelegate {
    
    
    @IBOutlet weak var bannerView: GADBannerView!
        
    var gameItem: String!
    //var scene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let request = GADRequest()
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        if let view = self.view as! SKView? {
            switch gameItem {
            case "bb":
               let scene = MenuScene_bb(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                scene.gameVC = self
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "pop":
                let scene = MenuScene_pop(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                scene.gameVC = self
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "bt":
                let scene = MenuScene_bt(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                scene.gameVC = self
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "fb":
                let scene = MainMenuScene(size: view.bounds.size)
                scene.scaleMode = .aspectFit
                scene.gameVC = self
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "gs":
                let scene = MenuScene_gs(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                scene.gameVC = self
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "ss":
                let scene = MenuScene_ss(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                scene.gameVC = self
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "cs":
                let scene = MenuScene_cs(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                scene.gameVC = self
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "sim":
                let scene = MenuScene_sim(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                scene.gameVC = self
                view.ignoresSiblingOrder = true
                view.presentScene(scene)
            case "split":
                let scene = MenuScene_split(fileNamed: "MenuScene_Split")
                scene?.scaleMode = .aspectFit
                scene?.gameVC = self
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

