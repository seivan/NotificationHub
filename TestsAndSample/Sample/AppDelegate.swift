//
//  AppDelegate.swift
//  Sample
//
//  Created by Seivan Heidari on 02/11/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!


  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application
    
    

    var x = NSNotificationCenter.defaultCenter().addObserverForName("x", object: nil, queue: nil) { n in
      println("WITHOUT NIL");
    }

    var p = NSNotificationCenter.defaultCenter().addObserverForName("x", object: self, queue: nil) { n in
      println("WITH NIL");
    }

//    NSNotificationCenter.defaultCenter().removeObserver(x, name: "x", object: nil)
//    NSNotificationCenter.defaultCenter().postNotificationName("x", object: nil)
    NSNotificationCenter.defaultCenter().postNotificationName("x", object: self)
    
//    var windowNotifications = NotificationHub<[String:NSWindow]>()
//    
//    windowNotifications.subscribeNotificationForName("Damn", sender: nil) { not in
//      print(not.userInfo)
//    }
//  
//    windowNotifications.publishNotificationName("Damn", sender: nil, userInfo: ["fuck" : self.window])
//
//    
//    NotificationHubDefault.subscribeNotificationForName("fuck", block: { notification in
//      println(notification)
//    })
//
//    NotificationHubDefault.subscribeNotificationForName("fuck", block: { notification in
//      println(notification)
//    })
//    
//    NotificationHubDefault.publishNotificationName("AFK", userInfo: ["asd" : "asd"])
//    NotificationHubDefault.publishNotificationName("AFK", sender:self)
//    NotificationHubDefault.publishNotificationName("AFK")
    

  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }


}

