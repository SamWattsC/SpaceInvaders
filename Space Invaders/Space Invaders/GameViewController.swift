//
//  GameViewController.swift
//  Space Invaders
//
//  Created by Sam Watts on 10/28/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
                // Present the scene
                if let view = self.view as! SKView? {
                    
                    let scene = MainMenuScene (size: CGSize(width: 1536, height: 2048))
                    
                   // view.presentScene(sceneNode)
                    
                    view.presentScene(scene)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
