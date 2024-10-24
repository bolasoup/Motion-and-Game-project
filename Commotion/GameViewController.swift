//
//  GameViewController.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var totalScore = 10
    @IBOutlet weak var gameLabel: UILabel!
    
    @IBOutlet weak var gameLabel2: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup game scene
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView // the view in storyboard must be an SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        gameLabel.text = "Don't touch the sides!"
        gameLabel2.text = String(self.totalScore)
    }

    
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    


}
