//
//  CollectionVC.swift
//  BrickBreaker
//
//  Created by Pete Connor on 4/12/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import UIKit
import StoreKit
import GameKit

class CollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GKGameCenterControllerDelegate {
    
    let gameItems = Singleton.shared.gameItems
    
    var gcEnabled = Bool()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        authenticateLocalPlayer()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! CustomCell
        cell.imageView.image = UIImage(named: "image_\(gameItems[indexPath.row])")
        if self.traitCollection.forceTouchCapability != UIForceTouchCapability.available && cell.imageView.image == UIImage(named: "image_split") {
            cell.alpha = 0.2
        }
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var bool = Bool()
        let indexPath = self.collectionView.indexPath(for: sender as! UICollectionViewCell)!
        if identifier == "ShowGameVC" && self.traitCollection.forceTouchCapability != UIForceTouchCapability.available && gameItems[indexPath.row] == "split" {
            bool = false
            showAlert()
        } else {
            bool = true
        }
        return bool
    }
    
    func showAlert() {
        let myAlert: UIAlertController = UIAlertController(title: "3D Touch Alert", message: "Banana Split requires 3D Touch, which this device does not support. Please choose another game or use a device that supports 3D Touch", preferredStyle: .alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowGameVC" {
            
            let newViewController = segue.destination as! GameViewController2
            let indexPath = self.collectionView.indexPath(for: sender as! UICollectionViewCell)!
            newViewController.gameItem = gameItems[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 3 - 1
        let height = collectionView.frame.size.height / 3  - 1
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

    @IBAction func shareButtonAction(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: ["https://itunes.apple.com/us/app/minigames/id1378113348?ls=1&mt=8"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func rateButtonAction(_ sender: Any) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            
        }
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController, error) -> Void in
            
            if ((viewController) != nil) {
                self.present(viewController!, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                self.gcEnabled = true
            } else {
                self.gcEnabled = false
                print(error?.localizedDescription ?? "error")
            }
            
        }
    }
    
    
    @IBAction func combinedLeaderButton(_ sender: Any) {
        
        submitScore()
        
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "MiniGames! - All Games"
        self.present(gcVC, animated: true, completion: nil)
        }
    
    func submitScore() {
        let leaderboardID = "MiniGames! - All Games"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(UserDefaults.standard.integer(forKey: "HighScore_split") + UserDefaults.standard.integer(forKey: "HighScore_sim") + UserDefaults.standard.integer(forKey: "HighScore_gs") + UserDefaults.standard.integer(forKey: "HighScore_fb") + UserDefaults.standard.integer(forKey: "HighScore_bb") + UserDefaults.standard.integer(forKey: "HighScore_cs") + UserDefaults.standard.integer(forKey: "HighScore_bt") + UserDefaults.standard.integer(forKey: "HighScore_pop") + UserDefaults.standard.integer(forKey: "HighScore_ss"))
        GKScore.report([sScore]) { (error: Error!) -> Void in
            if error != nil {
                print(error.localizedDescription)
            } else {
                print("Score Submitted")
                
            }
        }
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}
