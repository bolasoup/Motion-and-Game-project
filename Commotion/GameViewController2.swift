//
//  GameViewController2.swift
//  Commotion
//
//  Created by Christian Melendez on 10/22/24.
//  Copyright © 2024 Eric Larson. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController2: UIViewController {

    
    @IBOutlet weak var Game2Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup game scene
        let scene = GameScene2(size: view.bounds.size)
        let skView = view as! SKView // the view in storyboard must be an SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        Game2Label.text = "Move Slow"
    }

    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    


}
