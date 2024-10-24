//
//  GameScene.swift
//  Commotion
//
//  Created by Christian Melendez on 10/22/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Timer variables
    var timer: Timer?
        var elapsedTime: TimeInterval = 0 {
            willSet {
                DispatchQueue.main.async {
                    self.timerLabel.text = String(format: "Time: %.1f", newValue)
                }
            }
        }
        
        let timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        
        // Other properties and methods...
    
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()

    //Our Gyro updater
    func startGyroUpdates(){
        if self.motion.isGyroAvailable{
            self.motion.gyroUpdateInterval = 0.1
            self.motion.startGyroUpdates(to: OperationQueue.main, withHandler: self.handleGyro)
        }
    }
    
    func handleGyro(_ gyroData: CMGyroData?, error:Error?){
        if let data = gyroData {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(4.9*data.rotationRate.y), dy: CGFloat(-4.9*data.rotationRate.x))
            //dump(data.rotationRate.z as Any)
        }
        
    }
    
    // MARK: View Hierarchy Functions
    //let spinBlock = SKSpriteNode()
    //let goal = SKSpriteNode(imageNamed: "goal")
    /*let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }*/
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        
        // start gyro updates
        self.startGyroUpdates()
        
        // make sides to the screen
        self.addSidesAndTop()
        
        // add some stationary blocks
        //self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.1, y: size.height * 0.25))
        //self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.9, y: size.height * 0.25))
        
        // add a spinning block
        //self.addBlockAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.35))
        
        //self.addGoal()
        self.addBall()
        self.setupTimerLabel()
            
        // Start the timer
        startTimer()
        
        //self.addScore()
        
        //self.score = 0
    }
    
    // setup the timer
    func setupTimerLabel() {
        timerLabel.fontSize = 20
        timerLabel.fontColor = SKColor.blue
        timerLabel.position = CGPoint(x: frame.midX, y: frame.minY + 20)
        
        addChild(timerLabel)
    }
    
    func startTimer() {
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 0.1
        }
    }
    
    // MARK: Create Sprites Functions
    /*func addScore(){
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY)
        
        addChild(scoreLabel)
    }*/
    
    
    /*func addGoal(){
        //let spriteA = SKSpriteNode(imageNamed: "goal") // just a goal that I made by hand, I am not an artist - Christian Melendez
        
        goal.size = CGSize(width:size.width*0.3,height:size.height * 0.2)
        
        //let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        goal.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        
        goal.physicsBody = SKPhysicsBody(rectangleOf:CGSize(width:size.width*0.15,height:size.height * 0.05))
        goal.physicsBody?.restitution = random(min: CGFloat(0.0), max: CGFloat(0.0))
        goal.physicsBody?.isDynamic = false
        goal.physicsBody?.contactTestBitMask = 0x00000001
        goal.physicsBody?.collisionBitMask = 0x00000001
        goal.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(goal)
    }*/
    func addBall(){
        let spriteA = SKSpriteNode(imageNamed: "soccer") // just a goal that I made by hand, I am not an artist - Christian Melendez
        
        spriteA.size = CGSize(width:size.width*0.1,height:size.height * 0.075)
        
        //let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        spriteA.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        
        spriteA.physicsBody = SKPhysicsBody(rectangleOf:spriteA.size)
        spriteA.physicsBody?.restitution = random(min: CGFloat(0.0), max: CGFloat(0.0))
        spriteA.physicsBody?.isDynamic = true
        spriteA.physicsBody?.contactTestBitMask = 0x00000001
        spriteA.physicsBody?.collisionBitMask = 0x00000001
        spriteA.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(spriteA)
    }
    
    /*func addBlockAtPoint(_ point:CGPoint){
        
        spinBlock.color = UIColor.red
        spinBlock.size = CGSize(width:size.width*0.15,height:size.height * 0.05)
        spinBlock.position = point
        
        spinBlock.physicsBody = SKPhysicsBody(rectangleOf:spinBlock.size)
        spinBlock.physicsBody?.contactTestBitMask = 0x00000001
        spinBlock.physicsBody?.collisionBitMask = 0x00000001
        spinBlock.physicsBody?.categoryBitMask = 0x00000001
        spinBlock.physicsBody?.isDynamic = true
        spinBlock.physicsBody?.pinned = true
        
        self.addChild(spinBlock)

    }*/
    
    func addStaticBlockAtPoint(_ point:CGPoint){
        let 🔲 = SKSpriteNode()
        
        🔲.color = UIColor.red
        🔲.size = CGSize(width:size.width*0.1,height:size.height * 0.05)
        🔲.position = point
        
        🔲.physicsBody = SKPhysicsBody(rectangleOf:🔲.size)
        🔲.physicsBody?.isDynamic = true
        🔲.physicsBody?.pinned = true
        🔲.physicsBody?.allowsRotation = true
        
        self.addChild(🔲)
        
    }
    
    func addSidesAndTop(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        let bottom = SKSpriteNode()
        /* Original
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.1)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        bottom.size = CGSize(width:size.width,height:size.height*0.1)
        bottom.position = CGPoint(x:size.width*0.5, y:0)
        */
        left.size = CGSize(width:size.width*0.1,height:size.height*0.4)
        left.position = CGPoint(x:size.width*0.25, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height*0.4)
        right.position = CGPoint(x:size.width*0.75, y:size.height*0.5)
        
        top.size = CGSize(width:size.width*0.5,height:size.height*0.05)
        top.position = CGPoint(x:size.width*0.5, y:size.height*0.7)
        
        bottom.size = CGSize(width:size.width*0.5,height:size.height*0.05)
        bottom.position = CGPoint(x:size.width*0.5, y:size.height*0.3)
        
        
        for obj in [left, right] {
                obj.color = UIColor.red
                obj.physicsBody = SKPhysicsBody(rectangleOf: obj.size)
                obj.physicsBody?.isDynamic = false // Make them static
                obj.physicsBody?.categoryBitMask = 0x00000002 // Unique category for sides
                obj.physicsBody?.contactTestBitMask = 0x00000001 // Detect collisions with the ball
                obj.physicsBody?.collisionBitMask = 0 // Do not collide with anything
                self.addChild(obj)
            }
        
        for obj in [top, bottom] {
                obj.color = UIColor.green
                obj.physicsBody = SKPhysicsBody(rectangleOf: obj.size)
                obj.physicsBody?.isDynamic = false // Make them static
                obj.physicsBody?.allowsRotation = false
                self.addChild(obj)
            }
    }
    
    // MARK: =====Delegate Functions=====
    /*override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addBall()
    }*/
    
    /*func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == goal || contact.bodyB.node == goal {
            self.score += 1
        }
        //add the negative scoring later
    }*/
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(Int.max))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    //this func is to end timer if ball touches the sides
    func didBegin(_ contact: SKPhysicsContact) {
            if (contact.bodyA.categoryBitMask == 0x00000001 && contact.bodyB.categoryBitMask == 0x00000002) ||
               (contact.bodyA.categoryBitMask == 0x00000002 && contact.bodyB.categoryBitMask == 0x00000001) {
                endGame() // End the game if the ball touches the sides
            }
        }
    
    func endGame() {
        // Stop the timer
        timer?.invalidate()
        timer = nil
        
        // Show final score or alert with elapsed time
        let alert = UIAlertController(title: "Game Over", message: "Time: \(String(format: "%.1f", elapsedTime)) seconds", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        
        
    }
}


