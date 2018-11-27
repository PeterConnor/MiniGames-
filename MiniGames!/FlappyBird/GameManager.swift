//
//  GameManager.swift
//  FlappyBird
//
//  Created by Pete Connor on 4/28/18.
//  Copyright © 2018 c0nman. All rights reserved.
//
//

import Foundation
import SpriteKit

class GameManager {
    static let instance = GameManager()
    private init() {}
    
    var birdIndex = Int(0)
    var birds = ["Blue", "Green", "Red"]
    
    func incrementIndex() {
        birdIndex += 1
        if birdIndex == birds.count {
            birdIndex = 0
        }
    }
    
    func getBird() -> String {
        return birds[birdIndex]
    }
    
    func setHighscore(highscore: Int) {
        UserDefaults.standard.set(highscore, forKey: "Highscore")
    }
    
    func getHighscore() -> Int {
        return UserDefaults.standard.integer(forKey: "Highscore")
    }
    
    
    
}
