//
//  GameViewController.swift
//  Flight
//
//  Created by Ruvim on 24.02.2021.
//

import SceneKit

class GameViewController: UIViewController {
    
    //Flag to kill the plane
    var killThePlane = false

    /// Duration of the plane animation
    var duration: TimeInterval = 5 {
        didSet {
            print(#line, #function, duration)
        }
    }
    
    /// Label with the score
    let scoreLabel = UILabel()
    
    /// Number of planes shot dawn
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    /// The ship which is present on the scene
    var ship: SCNNode?
    
    func addShip() {
        

        
        // Get a scene with the ship
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        //Find ship in the scene
        ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        //Set ship coordinates
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = -105
        
        ship?.position = SCNVector3(x, y, z)
        
        ship?.look(at: SCNVector3(2 * x, 2 * y, 2 * z))
        
        // Make the ship fly from far to the origin
        ship?.runAction(SCNAction.move(to: SCNVector3(), duration: duration)) {
            DispatchQueue.main.async {
                self.scoreLabel.text = "GAME OVER\nFinal Score: \(self.score)"
            }
            
            if self.killThePlane == true {
                return
            }
            
            self.ship?.removeFromParentNode()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.duration = 5
                self.score = 0
                self.addShip()
            }
        }
        
        // Get the scene
        let scnView = self.view as! SCNView

        // Add ship to the scene
        if let ship = ship {
        scnView.scene?.rootNode.addChildNode(ship)
        }
    }
    
    func setupUI() {
        score = 0
        
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.systemFont(ofSize: 25)
        scoreLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        scoreLabel.numberOfLines = 2
        scoreLabel.textAlignment = .center
        view.addSubview(scoreLabel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 0, z: 0)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        ship.removeFromParentNode()
        
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // Add the ship to scene
        addShip()
        
        // Setup UI
        setupUI()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        

        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
                
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            killThePlane = true
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2


            
            // on completion - unhighlight
            // MARK: Kill the plane
            SCNTransaction.completionBlock = {
                self.duration *= 0.9
                self.score += 1
                self.ship?.removeFromParentNode()
                self.addShip()
                self.killThePlane = false
            }
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
