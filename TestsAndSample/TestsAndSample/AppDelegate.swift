//
//  AppDelegate.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 29/06/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import UIKit
import SpriteKit




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
    let scene = SKScene(size: controller.view.frame.size)
    let skView = controller.view as SKView
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = true
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = .AspectFill
    scene.name = "MAAAAAAAAAAIn"
    skView.presentScene(scene)
    self.window?.rootViewController = controller
    
    
    

    var counter = 0
    var hub = NotificationHubDefault
    
    hub.addObserverForName("withoutSender", sender: nil) {
        println("withoutSender Success \(counter) \($0)")
        counter += 1
    }
    
    hub.postNotificationName("withoutSender", sender: nil, userInfo: nil)
    


//    NotificationHub.defaultHub.postNotification(notification)
//    NotificationHub.defaultHub.postNotificationName("withoutSender", sender: nil)
//    
//    NotificationHub.defaultHub.removeNotification("withoutSender")
//    
//    NotificationHub.defaultHub.postNotification(notification)
//    NotificationHub.defaultHub.postNotificationName("withoutSender", sender: nil)
//
////    
//    notification = NotificationHub.defaultHub.addObserverForName("withSender", sender: self) {
//      println("withSender Success \(counter) \($0)")
//      counter += 1
//    }
//    
//        NotificationHub.defaultHub.removeAllNotifications("asd")
//    NotificationHub.defaultHub.postNotificationName("withSender", sender: self)
//    NotificationHub.defaultHub.postNotificationName("withSender", sender: self)
//
//    NotificationHub.defaultHub.removeNotification("withSender", sender:self)
//
//    NotificationHub.defaultHub.postNotificationName("withSender", sender: self)
//    NotificationHub.defaultHub.postNotificationName("withSender", sender: self)
//

    let enemy = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 40, height: 40))
    enemy.name = "ENEMY"
    
    
    let player = SKSpriteNode(color: UIColor.blueColor(), size:  CGSize(width: 40, height: 40))
    player.name = "PLAYER"


    

    
    let gun = SKNode()
    gun.name = "GUN"
    player.addChild(gun)

    


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

