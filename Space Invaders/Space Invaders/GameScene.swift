//
//  GameScene.swift
//  Space Invaders
//
//  Created by Sam Watts on 10/28/23.
//

import SpriteKit
import GameplayKit

//Universal access to allow GamerOverScene to access it
var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    enum gameState{
        case preGame  //before the game starts
        case inGame   //during
        case endGame  //Game Over
    }
    
    var currentGameState = gameState.preGame
    
    //differentiates the physics body
    struct PhysicsCatagories{
        static let none: UInt32 = 0
        //number 1
        static let player: UInt32 = 0b1
        //number 2
        static let enemy: UInt32 = 0b10
        //number 4
        static let bullet: UInt32 = 0b100
    }
    
    //creates a random number for enemy spawns
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    let gameArea: CGRect
    
    override init(size: CGSize) {
        //calculates playable Area
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = ((size.width - playableWidth) / 2)
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //set initial scene
    override func didMove(to view: SKView) {
       
        //restarts the score every a new game starts
        gameScore = 0
        
        //adds physical body to our objects
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1{
            //sets background to same size of scene and centers it
            let background = SKSpriteNode(imageNamed: "background")
            background.name = "Background Reference"
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))
            background.zPosition = 0
            self.addChild(background)
            //sets the player and places it 20% up from the bottom of the screen
        }
        player.setScale(1)
        //starts the player below the field of view
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCatagories.player
        player.physicsBody!.collisionBitMask = PhysicsCatagories.none
        player.physicsBody!.contactTestBitMask = PhysicsCatagories.enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 50
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToSreenAction = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        scoreLabel.run(moveOnToSreenAction)
        livesLabel.run(moveOnToSreenAction)
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        tapToStartLabel.zPosition = 1
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }
        else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background Reference"){
            background, stop in
            
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height {
                background.position.y += self.size.height * 2
            }
        }
    }
   
    func loseALife(){
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if(livesNumber == 0){
            gameOver()
        }
    }
    
    func gameOver (){
        
        currentGameState = gameState.endGame
        
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "BulletReference") {
            bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "EnemyReference"){
            enemy, stop in
            enemy.removeAllActions()
            }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
            
        }
    
    func changeScene(){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }

    
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
    }
    //controls the contact interactions
    func didBegin(_ contact: SKPhysicsContact){
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        //if the enemy hits the player
        if body1.categoryBitMask == PhysicsCatagories.player && body2.categoryBitMask == PhysicsCatagories.enemy{
            
            //prevents crashes
            if body1.node != nil{
                createExplosion(spawnPosition: body1.node!.position)
            }
            if (body2.node != nil){
                createExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            gameOver()
        }
        //if the bullet hits the enemy
        if body1.categoryBitMask == PhysicsCatagories.enemy && body2.categoryBitMask == PhysicsCatagories.bullet{
            
            if (body1.node != nil){
                if (body1.node!.position.y > self.size.height){
                    return
                }
                else {
                    createExplosion(spawnPosition: body1.node!.position)
                    addScore()
                }
            }
           
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    func createExplosion (spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        
        self.addChild(explosion)
    
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let scaleOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, scaleOut, delete])
        
        explosion.run(explosionSequence)
        
    }
    
    func fireAway(){
        
        //starts the bullet at the position of the ship
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "BulletReference"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCatagories.bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCatagories.none
        bullet.physicsBody!.contactTestBitMask = PhysicsCatagories.enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    func startNewLevel(){
        
        levelNumber += 1
        
        //if we are spawning enemies, stop spawning
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber{
        case 1: levelDuration = 5
        case 2: levelDuration = 3
        case 3: levelDuration = 2
        case 4: levelDuration = 1
        default:
            levelDuration = 0.5
            print("No level found")
        }
        
        let spawn = SKAction.run(createEnemy)
        //adds a gap of 1 second between spawns
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        //runs the enemy spawns endlessly
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
        
    }
    
    func createEnemy(){
        
        let randomStart = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        let randomEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        
        //starts and ends the enemy path slightly above and below the screen
        let startPoint = CGPoint(x: randomStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomEnd, y: -self.size.height * 1.05)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "EnemyReference"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCatagories.enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCatagories.none
        enemy.physicsBody!.contactTestBitMask = PhysicsCatagories.bullet | PhysicsCatagories.player
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let rotate = atan2(dy, dx)
        enemy.zRotation = rotate
    }
    
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOnScreenAction = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOnScreenAction, startLevelAction])
        player.run(startGameSequence)
        
    }
    
    //fires when the player touches the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
        if (currentGameState == gameState.preGame){
            startGame()
        }
        
        else if (currentGameState == gameState.inGame){
            fireAway()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
           
            if (currentGameState == gameState.inGame){
                //moves the ship left or right based on touch
                player.position.x += amountDragged
            }
            //keeps the player in the game area
            if player.position.x > CGRectGetMaxX(gameArea){
                player.position.x = CGRectGetMaxX(gameArea)
            }
            if player.position.x < CGRectGetMinX(gameArea){
                player.position.x = CGRectGetMinX(gameArea)
            }
            
        }
        
    }
}
