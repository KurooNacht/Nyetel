//
//  GameViewController.swift
//  testing1234
//
//  Created by Juan Carlos Manuel on 30/04/24.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var tutupanBening : SCNNode!
    var tutupan : SCNNode!
    var needle : SCNNode!
    var tombolPink: SCNNode!
    var needleButton : SCNNode!
    var roomTurnTable : SCNNode!
    var vinyl : SCNNode!
    var vinylCam: SCNNode!
    var roomCam: SCNNode! // Declare roomCamNode as an instance variable
    var cameraNode: SCNNode!
    var isCubePressed = false
    var isNeedleRotate = false
    var isPinkPressed = false
    var sounds:[String:SCNAudioSource] = [:]
    var scnView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/test.scn")!
        
        // create and add a camera to the scene
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        scene.rootNode.addChildNode(cameraNode)
        
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        let roomCam = scene.rootNode.childNode(withName: "roomCam", recursively: true)!
        cameraNode.camera = roomCam.camera
        
        let vinylCam = scene.rootNode.childNode(withName: "vinylCam", recursively: true)!
        cameraNode.camera = vinylCam.camera
        
        scnView = self.view as! SCNView
        scnView.pointOfView = roomCam
        
        // retrieve the ship node
        roomTurnTable = scene.rootNode.childNode(withName: "Cube_009", recursively: true)
        vinyl = scene.rootNode.childNode(withName: "Circle", recursively: true)!
        needle = scene.rootNode.childNode(withName: "needle", recursively: true)!
        needleButton = scene.rootNode.childNode(withName: "Cube_007", recursively: true)!
        tutupanBening = scene.rootNode.childNode(withName: "tutupan", recursively: true)!
        tutupan = scene.rootNode.childNode(withName: "cover", recursively: true)!
        tombolPink = scene.rootNode.childNode(withName: "Cylinder", recursively: true)!
        
        
        // Create a sound source
              let music = SCNAudioSource(fileNamed: "art.scnassets/music.wav")!
              music.load()
            sounds["music"] = music
                      
        // retrieve the SCNView
//        let scnView = self.view as! SCNView
//        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        scnView.addGestureRecognizer(longPressGesture)

    }
    
//    @objc func handleVinylTap(_ gestureRecognize: UITapGestureRecognizer) {
//           // Switch camera POV from roomCamNode to cameraNode when vinyl is tapped
//           let scnView = self.view as! SCNView
//           scnView.pointOfView = cameraNode
//       }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // Handle the beginning of the long press here
        } else if gestureRecognizer.state == .ended {
            // Handle the end of the long press here
        }
    }
    
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        let isCoverButtonPressed = hitResults.contains { result in
            print("isCoverButtonPressed \(result.node.name)")
            return result.node.name == "cover"
        }
        let isNeedleButtonPressed = hitResults.contains {
              result in print("isNeedleButtonPressed\(result.node.name)")
                return result.node.name == "Cube_007"
        }
        let isPinkButtonPressed = hitResults.contains {
            result in print("isPinkButtonPressed\(result.node.name)")
            return result.node.name == "Cylinder"

        }
        let isRoomTurnTablePressed = hitResults.contains {
            result in print("isRoomTurnTablePressed\(result.node.name)")
            return result.node.name == "Cube_009"
        }
        
        if isRoomTurnTablePressed {
            scnView.pointOfView = vinylCam
        }
       
        
        if isPinkButtonPressed {
             if isPinkPressed {
                 // Reset the pink button position
                 let moveAction = SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.4)
                            tombolPink.runAction(moveAction)
                            // Stop the vinyl rotation
                            vinyl.removeAllActions()
                 let music = sounds["music"]
                 if let music = music {
                     vinyl.removeAllAudioPlayers()
                 }

                        } else {
                            // Move the pink button down
                            let moveAction = SCNAction.move(to: SCNVector3(0, 0, -0.6), duration: 0.2)
                            tombolPink.runAction(moveAction)
                 // Rotate the vinyl
                 let rotateAction = SCNAction.rotate(by: .pi / 2, around: SCNVector3(0, 0, 1), duration: 0.5)
                 let repeatForeverAction = SCNAction.repeatForever(rotateAction)
                 vinyl.runAction(repeatForeverAction)
                        if isNeedleRotate == true   
                            {  let music = sounds["music"]
                                if let music = music {
                                    let musicPlayer = SCNAudioPlayer(source: music)
                                    vinyl.addAudioPlayer(musicPlayer)}
                            }
                            
             }
             // Toggle the pink button state
             isPinkPressed.toggle()
         }
        
        if isNeedleButtonPressed {
            if  isNeedleRotate{
                
                triggerAnimatonNeedle(clockwise: false)
                let music = sounds["music"]
                if let music = music {
                    vinyl.removeAllAudioPlayers()
                }
            }else{
                triggerAnimatonNeedle(clockwise: true)
            }
            isNeedleRotate.toggle()
        }

        if isCoverButtonPressed {
              // Rotate the cover button node based on the state
              if isCubePressed {
                  // Rotate by deltaYaw1 if it's the first time
                  triggerRotation(clockwise: false)
              } else {
                  // Rotate by deltaYaw2 if it's not the first time
                  triggerRotation(clockwise: true)
              }
              // Toggle the cube pressed state for the next press
              isCubePressed.toggle()
          }
      }
    

        
    func triggerVinylAnimation() {
        
    }
    
      func triggerAnimatonNeedle(clockwise: Bool) {
        
        // Define the rotation angles
        let deltaX1seq = CGFloat(-20.0 * Double.pi / 180.0) // Convert degrees to radians
        let deltaX2seq = CGFloat(20.0 * Double.pi / 180.0)
        let deltaZ1seq = CGFloat(-30.0 * Double.pi / 180.0)
        let deltaZ2seq = CGFloat(30.0 * Double.pi / 180.0)
        
        let needleRotation1 : CGFloat = clockwise ? deltaX1seq : deltaX1seq
        let needleRotation2 : CGFloat = clockwise ? deltaZ1seq : deltaZ2seq
        let needleRotation3 : CGFloat = clockwise ? deltaX2seq : deltaX2seq
        
        let seq1 = SCNAction.rotateBy (x: needleRotation1, y: 0, z: 0, duration: 1.2)
        let seq2 = SCNAction.rotateBy (x: 0, y: 0, z: needleRotation2,duration: 1.0)
        let seq3 = SCNAction.rotateBy (x: needleRotation3, y: 0, z: 0, duration: 1.2)

        let sequence = SCNAction.sequence([seq1, seq2, seq3])
        print ("4")
        // Run the sequence on the turntable node
        needle.runAction(sequence)
    }

      // Function to trigger the rotation action
      func triggerRotation(clockwise: Bool) {
          // Calculate the change in Y Euler angle to rotate by 45 degrees
          let deltaYaw1 = CGFloat(-45.0 * Double.pi / 180.0) // Convert degrees to radians
          let deltaYaw2 = CGFloat(45.0 * Double.pi / 180.0) // Convert degrees to radians
          
          // Determine the rotation angle based on the input
          let rotationAngle: CGFloat = clockwise ? deltaYaw1 : deltaYaw2
          
          // Create the rotation action based on the rotation angle
          let rotation = SCNAction.rotateBy(x: 0, y: rotationAngle, z: 0, duration: 1.0)
          
          // Apply the rotation action to the coverNode
          tutupanBening.runAction(rotation)
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
