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
    
    var x = NSNotificationCenter.defaultCenter().addObserverForName("test", object: nil, queue: nil) { n in
      println("WITHOUT");
    }

        NSNotificationCenter.defaultCenter().removeObserver(x, name: "test", object: nil)
    NSNotificationCenter.defaultCenter().postNotificationName("test", object: nil)
    NSNotificationCenter.defaultCenter().postNotificationName("test", object: self)
    

    x = NSNotificationCenter.defaultCenter().addObserverForName("x", object: self, queue: nil) { n in
      println("WITH");
    }
    
    NSNotificationCenter.defaultCenter().removeObserver(x, name: "x", object: nil)
    NSNotificationCenter.defaultCenter().postNotificationName("x", object: nil)
    NSNotificationCenter.defaultCenter().postNotificationName("x", object: self)
    
    var windowNotifications = NotificationHub<[String:NSWindow]>()
    
    windowNotifications.addObserverForName("Damn", sender: nil) { not in
      print(not.userInfo)
    }
  
    windowNotifications.postNotificationName("Damn", sender: nil, userInfo: ["fuck" : self.window])


  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }


}

