import SpriteKit

class GameScene_gs: SKScene, SKPhysicsContactDelegate {
    
    //var gameTimer: Timer!
    
    var isGamePaused = false
    
    weak var gameVC: GameViewController2?
    
    var itemController = ItemController()
    
    var player = Player_gs()
    var table = SKSpriteNode()
    
    var center = CGFloat()
    
    var pauseButton = SKSpriteNode()
    
    var canMove = false
    var gameOver = false
    
    var moveLeft = false
    
    var scoreLabel = SKLabelNode()
    var score = 0
    
    override func didMove(to view: SKView) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene_gs.pauseGame), name: NSNotification.Name(rawValue: "PauseGame"), object: nil)
        
        backgroundColor = UIColor(red: 102/255, green: 178/255, blue: 255/255, alpha: 1)
        addBackButton()
        addTable()
        initializeGame()
        addPauseButton()
        
        
    }
    
    var lastUpdateTimeInterval = TimeInterval()
    var lastYieldTimeInterval = TimeInterval()
    var lastUpdate = TimeInterval()
    var lastYield = TimeInterval()
    var timeCheck = 0
    
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate: CFTimeInterval) {
        if isGamePaused == false {
            lastYieldTimeInterval += timeSinceLastUpdate
            if lastYieldTimeInterval > 0.01 {
                lastYieldTimeInterval = 0
                managePlayer()
            }
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        var timeSinceLastUpdate = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        
        if timeSinceLastUpdate > 1 {
            timeSinceLastUpdate = 1/60
            lastUpdateTimeInterval = currentTime
        }
        updateWithTimeSinceLastUpdate(timeSinceLastUpdate: timeSinceLastUpdate)
        
        if isGamePaused == false && gameOver == false {
            if timeCheck == 1 {
                lastUpdate = currentTime
                timeCheck = 0
            }
            var timeSince = currentTime - lastUpdate
            lastUpdate = currentTime
            lastYield += timeSinceLastUpdate
            if lastYield > 0.49 {
                lastYield = 0
                spawnItems()
            }
        }
        
        removeItems()
    }
    
    func initializeGame() {
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - scoreLabel.frame.height - 60)
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 80.0
        addChild(scoreLabel)
        
        
        physicsWorld.contactDelegate = self
        player = Player_gs(imageNamed: "Granny")
        player.initializePlayer()
        player.size.width = 187
        player.size.height = 328
        player.position.x = frame.midX
        player.position.y = table.frame.maxY + player.size.height/2 - player.size.height * 0.01
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: CGSize(width: player.size.width * 0.95, height: player.size.height * 0.95))        //physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width - CGFloat(20), height: self.size.height - CGFloat(15)))
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = ColliderType_gs.Player
        player.physicsBody?.contactTestBitMask = ColliderType_gs.FruitAndBomb
        
        self.addChild(player)
        
        center = self.frame.size.width / self.frame.size.height
        
        //gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene_gs.spawnItems), userInfo: nil, repeats: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        canMove = true
        canMove = true
        for touch in touches {
            
            let location = touch.location(in: self)
            if atPoint(location).name == "BackButton" {
                let mainMenu = MenuScene_gs(size: view!.bounds.size)
                mainMenu.gameVC = self.gameVC
                mainMenu.scaleMode = .aspectFill
                self.view?.presentScene(mainMenu, transition: SKTransition.flipHorizontal(withDuration: 1))
            }
            
            if atPoint(location).name == "PauseButton" {
                if isGamePaused == false {
                    pauseGame()
                } else {
                    isGamePaused = false
                    self.isPaused = false
                    self.speed = 1.0
                    self.physicsWorld.speed = 1.0
                    pauseButton.texture = SKTexture(imageNamed: "PauseButtonWhite")
                    if !gameOver {
                        //gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene_gs.spawnItems), userInfo: nil, repeats: true)
                    }
                }
            }
            
            if atPoint(location).name != "PauseButton" {
                if location.x > center {
                    moveLeft = false
                } else {
                    moveLeft = true
                }
            }
        }
    }
    
    @objc func pauseGame() {
        timeCheck = 1
        self.isPaused = true
        isGamePaused = true
        pauseButton.texture = SKTexture(imageNamed: "PlayButtonWhite")
        //gameTimer.invalidate()
        self.speed = 0.0
        self.physicsWorld.speed = 0.0
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        canMove = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //canMove = false
    }
    
    private func managePlayer() {
        if canMove && !gameOver {
            player.move(left: moveLeft)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Fruit" {
            score += 1
            secondBody.node?.name = "nil"
            scoreLabel.text = "\(score)"
            secondBody.node?.removeFromParent()
        }
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Bomb" {
            //firstBody.node?.removeFromParent()
            //secondBody.node?.removeFromParent()
            backgroundColor = .red
           // gameTimer.invalidate()
            gameOver = true
            
            for child in children {
                child.physicsBody?.isDynamic = false
                player.physicsBody?.isDynamic = false
                child.removeAllActions()
                
            }
            
            UserDefaults.standard.set(score, forKey: "RecentScore_gs")
            if score > UserDefaults.standard.integer(forKey: "HighScore_gs") {
                UserDefaults.standard.set(score, forKey: "HighScore_gs")
            }
            
            self.run(SKAction.wait(forDuration: 2)) {
                let mainMenu = MenuScene_gs(size: self.view!.bounds.size)
                mainMenu.gameVC = self.gameVC
                mainMenu.scaleMode = .aspectFill
                self.view?.presentScene(mainMenu, transition: SKTransition.flipHorizontal(withDuration: 1))
            }
            
            //Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(GameScene_gs.restartGame), userInfo: nil, repeats: false)
            
            Timer.scheduledTimer(timeInterval: TimeInterval(2), target: self, selector: #selector(GameScene_gs.removeItems), userInfo: nil, repeats: false)
        }
    }
    
    @objc func spawnItems() {
        self.scene?.addChild(itemController.spawnItems())
    }
    
    @objc func restartGame() {
        if let scene = GameScene_gs(fileNamed: "GameScene_gs") {
            scene.scaleMode = .aspectFit
            view?.presentScene(scene, transition: SKTransition.doorway(withDuration: 1.0))
            
        }
        
    }
    
    @objc func removeItems() {
        for child in children {
            if child.name == "Fruit" || child.name == "Bomb" {
                if child.position.y < -self.scene!.frame.height {
                    child.removeFromParent()
                }
            }
        }
    }
    
    func addTable() {
        table = SKSpriteNode(imageNamed: "Table")
        table.size.width = self.size.width
        table.size.height = table.size.width * 0.2
        table.anchorPoint = CGPoint(x: 0.5, y: 0)
        table.position = CGPoint(x: frame.midX, y: frame.minY)
        table.zPosition = 5
        addChild(table)
    }
    
    func addBackButton() {
        let backButton = SKSpriteNode(texture: SKTexture(imageNamed: "BackButton"))
        backButton.name = "BackButton"
        backButton.size.width = frame.size.width/10
        backButton.size.height = backButton.size.width
        backButton.position = CGPoint(x: frame.minX + backButton.size.width/2, y: frame.maxY - backButton.size.height/2 - 40)
        backButton.zPosition = 6
        addChild(backButton)
    }
    
    func addPauseButton() {
        pauseButton = SKSpriteNode(texture: SKTexture(imageNamed: "PauseButtonWhite"))
        pauseButton.name = "PauseButton"
        pauseButton.size.width = frame.size.width/10
        pauseButton.size.height = pauseButton.size.width
        pauseButton.position = CGPoint(x: frame.maxX - pauseButton.size.width/2, y: frame.maxY - pauseButton.size.height/2 - 40)
        pauseButton.zPosition = 6
        addChild(pauseButton)
        
    }
}
