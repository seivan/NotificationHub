//
//  AppDelegate.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 29/06/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import UIKit
import SpriteKit


class Player : SKSpriteNode {


  override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
    super.init(texture:texture, color:color, size:size)
  }
  
  init(color: UIColor!, size: CGSize) {
    super.init()
    self.color = color
    self.size = size
  }
  

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
      fatalError("init(coder:) has not been implemented")
  }
  
  func didEndContact(contact: SKPhysicsContact) {
    println("DID END CONTACT")
  }
  
}

//color: UIColor.blueColor(), size: CGSize(width: 40, height: 40))

class Toucher : Component {

  func didAddToNode() {
    self.node?.userInteractionEnabled = true
  }

  func touchesBegan(touches: [UITouch], withEvent event: UIEvent) {
    println("TOUCH \(self.node?.name)")
  }
}

class MyScene : SKScene {
  override func update(currentTime: NSTimeInterval) {
    super.update(currentTime)
  }
  override func didEvaluateActions() {
    super.didEvaluateActions()
  }
  override func didSimulatePhysics() {
    super.didSimulatePhysics()
  }
  override func didFinishUpdate() {
    super.didSimulatePhysics()
  }
  override func didEndContact(contact: SKPhysicsContact) {
    super.didEndContact(contact)
  }

 
}

class SceneDebugger : Component {
  func didAddToNode() {
    let skView = (self.node as SKScene).view
    skView?.showsFPS = true
    skView?.showsNodeCount = true
    skView?.showsDrawCount = true
    skView?.showsQuadCount = true
    skView?.showsPhysics = true
    skView?.showsFields = true
    skView?.setValue(NSNumber(bool: true), forKey: "_showsCulledNodesInNodeCount")
//    skView?.multipleTouchEnabled = true
  }
}

class GravityLessBounds : Component {
  func didAddToNode() {
    let scene = (self.node as SKScene)
    scene.physicsWorld.gravity = CGVector(0,0)
    scene.physicsBody = SKPhysicsBody(edgeLoopFromRect: scene.frame)
  }
  
}

enum Contact : UInt32 {
  case Pinned
  case Moving
}

class Physical : Component {
  func didAddToNode() {
    self.node?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 40))
  }
  
}

class Pinned : Component {
//   override func didAddToNode() {
   func didAddToNode() {
//    super.didAddToNode()
    self.node?.physicsBody = nil
    self.node?.position = CGPoint(x: 200, y: 200)
    self.node?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 40))
    self.node?.physicsBody?.categoryBitMask = Contact.Pinned.rawValue
    self.node?.physicsBody?.contactTestBitMask = Contact.Moving.rawValue
    self.node?.physicsBody?.collisionBitMask = Contact.Moving.rawValue

  }
  
  func didEndContact(contact:SKPhysicsContact) {
    self.node?.removeComponentWithClass(Pinned.self)
    self.node?.addComponent(Pinned())
    
  }

}


class Reseting : Component {

  func didAddToNode() {
    self.node?.physicsBody = nil
    self.node?.position = CGPoint(x: 100, y: 100)
    self.node?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 40))
    self.node?.physicsBody?.categoryBitMask = Contact.Moving.rawValue
    self.node?.physicsBody?.contactTestBitMask = Contact.Pinned.rawValue
    self.node?.physicsBody?.collisionBitMask = Contact.Pinned.rawValue
  }
  
  func didAddNodeToScene() {
    self.node?.physicsBody?.applyImpulse(CGVector(5.0,5.0))
  }
  
  func didEndContact(contact:SKPhysicsContact) {
    self.node?.removeComponent(self)
    self.node?.addComponent(Reseting())

  }


}





@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
    // Override point for customization after application launch.
    self.window!.backgroundColor = UIColor.whiteColor()
    self.window!.makeKeyAndVisible()
    let controller = UIViewController()
    controller.view = SKView(frame: controller.view.frame)
    // Configure the view.
    let scene = MyScene(size: controller.view.frame.size)
    let skView = controller.view as SKView
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = true
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = .AspectFill
    scene.name = "MAAAAAAAAAAIn"
    skView.presentScene(scene)
    self.window?.rootViewController = controller
    
    
    


    

    let enemy = Player(color: UIColor.redColor(), size: CGSize(width: 40, height: 40))
    enemy.name = "ENEMY"
    
    
    let player = Player(color: UIColor.blueColor(), size:  CGSize(width: 40, height: 40))
    player.name = "PLAYER"


    

    
    let gun = SKNode()
    gun.name = "GUN"
    player.addChild(gun)

    
//    enemy.addComponent(Reseting())
//    player.addComponent(Pinned())
//
//    
//    scene.addComponent(GravityLessBounds())
    scene.addComponent(SceneDebugger())
    
//    scene.addComponent(Toucher())
//    player.addComponent(Toucher())

    scene.addChild(enemy)
    scene.addChild(player)

    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

