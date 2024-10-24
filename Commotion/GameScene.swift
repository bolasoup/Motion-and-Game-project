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
    var startScore = 0
    
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
    let ball = SKSpriteNode(imageNamed: "soccer")

    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        
        // start gyro updates
        self.startGyroUpdates()
        
        // make sides to the screen
        self.addSidesAndTopAndBottom()
        
        self.addBall()
        self.setupTimerLabel()
            
        // Start the timer
        startTimer()
        

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

    func addBall(){

        ball.size = CGSize(width:size.width*0.1,height:size.height * 0.075)
        

        ball.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        
        ball.physicsBody = SKPhysicsBody(rectangleOf:ball.size)
        ball.physicsBody?.restitution = random(min: CGFloat(0.0), max: CGFloat(0.0))
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.contactTestBitMask = 0x00000001
        ball.physicsBody?.collisionBitMask = 0x00000001
        ball.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(ball)
    }
    

    
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
    
    func addSidesAndTopAndBottom(){
        let left = SKSpriteNode()
        let right = SKSpriteNode()
        let top = SKSpriteNode()
        let bottom = SKSpriteNode()

        left.size = CGSize(width:size.width*0.1,height:size.height*0.4)
        left.position = CGPoint(x:size.width*0.25, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height*0.4)
        right.position = CGPoint(x:size.width*0.75, y:size.height*0.5)
        
        top.size = CGSize(width:size.width*0.5,height:size.height*0.05)
        top.position = CGPoint(x:size.width*0.5, y:size.height*0.7)
        
        bottom.size = CGSize(width:size.width*0.5,height:size.height*0.05)
        bottom.position = CGPoint(x:size.width*0.5, y:size.height*0.3)
        
        

        
        for obj in [top, bottom, left, right] {
                obj.color = UIColor.green
                obj.physicsBody = SKPhysicsBody(rectangleOf: obj.size)
                obj.physicsBody?.isDynamic = false // Make them static
                obj.physicsBody?.allowsRotation = false
                self.addChild(obj)
            }
    }
    
    // MARK: =====Delegate Functions=====

    // For every 1000 steps you get 1 extra life to touch the walls.
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == ball || contact.bodyB.node == ball {
            //self.totalScore += 1
            self.startScore -= 1000
            if self.startScore < 0 {
                endGame()
            }
        }
        //add the negative scoring later
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(Int.max))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
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


