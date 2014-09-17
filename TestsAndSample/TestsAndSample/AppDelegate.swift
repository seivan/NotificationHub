//
//  AppDelegate.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 29/06/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import UIKit
import SpriteKit



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
  var isEnabled:Bool = true
  weak var node:SKNode?
  func didAddToNode() {
    let skView = (self.node as SKScene).view
    skView?.showsFPS = true
    skView?.showsNodeCount = true
    skView?.showsDrawCount = true
    skView?.showsQuadCount = true
    skView?.showsPhysics = true
    skView?.showsFields = true
    skView?.setValue(NSNumber(bool: true), forKey: "_showsCulledNodesInNodeCount")
  }
  
}

class GravityLessBounds : Component {
  var isEnabled:Bool = true
  weak var node:SKNode?
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
  var isEnabled:Bool = true
  weak var node:SKNode?
  func didAddToNode() {
    self.node?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 40))
  }
  
}

class Pinned : Component {
  var isEnabled:Bool = true
  weak var node:SKNode?

  func didAddToNode() {
    self.node?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 40))
    self.node?.physicsBody?.categoryBitMask = Contact.Pinned.toRaw()
    self.node?.physicsBody?.contactTestBitMask = Contact.Moving.toRaw()
    self.node?.physicsBody?.collisionBitMask = Contact.Moving.toRaw()

  }
}


class Reseting : Component {
  var isEnabled:Bool = true
  weak var node:SKNode?

  func didAddToNode() {
    self.node?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 40))
    let p = self.node?.physicsBody
    self.node?.physicsBody = nil
    self.node?.position = CGPoint(x: 100, y: 100)
    self.node?.physicsBody = p
    self.node?.physicsBody?.categoryBitMask = Contact.Moving.toRaw()
    self.node?.physicsBody?.contactTestBitMask = Contact.Pinned.toRaw()
    self.node?.physicsBody?.collisionBitMask = Contact.Pinned.toRaw()
  }
  func didAddNodeToScene() {
    println("didAddNodeToScene Movement \(self.node?.name) and scene \(self.node?.scene?.name)")
    self.node?.physicsBody?.applyImpulse(CGVector(5.0,5.0))
  }
  
  func didEndContact(contact:SKPhysicsContact) {
    let node = self.node!
//    self.node?.removeComponentWithClass(Reseting.self)
//    node.addComponent(Reseting())
    self.node?.componentWithClass(Reseting.self)?.didAddToNode?()



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
    
    
    


    

    let enemy = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 40, height: 40))
    enemy.position = CGPoint(x: 100, y: 100)
    enemy.name = "ENEMY"
    
    
    let player = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: 40, height: 40))
    player.position = CGPoint(x: 200, y: 200)
    player.name = "PLAYER"


    

    
    let gun = SKNode()
    gun.name = "GUN"
    player.addChild(gun)

    
    enemy.addComponent(Reseting())
    player.addComponent(Pinned())
//    gun.addComponent(Life())
    
    scene.addComponent(GravityLessBounds())
    scene.addComponent(SceneDebugger())
    
    scene.addChild(enemy)
    scene.addChild(player)

//    scene.removeChildrenInArray([player,gun])
//    scene.insertChild(player, atIndex: 0)
//    let g = SKScene()
//    g.name = "GGGGGGGGGGG"
//    skView.presentScene(g)
//     g.addChild(player)

//    scene.insertChild(player, atIndex: 0)
//    scene.removeChildrenInArray([player])
    
    
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

