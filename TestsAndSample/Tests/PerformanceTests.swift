//
//  PerformanceTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 04/10/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//


import XCTest

class PerformanceTests: XCTestCase {
  var X_hub = NotificationHub<[String:String]>()
  var hub = NotificationHub<[String:String]>()
  var center = NSNotificationCenter()
  let limit = 1000
  let recursiveLimit = 200
  
  override func setUp() {
    super.setUp()
    self.X_hub = NotificationHub<[String:String]>()
    self.hub = NotificationHub<[String:String]>()
    self.center = NSNotificationCenter()

  }
  //////////////////////////////////////////////////////////////////////////
  
  func testExperimentalSubscribeSeveral() {
    
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        for j in 0...self.recursiveLimit {
          self.X_hub.X_subscribeNotificationForName(String(j), sender: nil) { not in}
        }
      }
      return
    }
    
  }
  
  func testSubscribeSeveral() {
    
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        for j in 0...self.recursiveLimit {
          self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
        }
      }
      return
    }
    
  }
  
  
  func testAppleSubscribeSeveral() {
    
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        for j in 0...self.recursiveLimit {
          self.center.addObserverForName(String(j), object: nil, queue: nil) { not in }
        }
      }
      return
    }
    
  }

  
  ////////////////////////////////////////////////////////////////////////
  
  func testExperimentalPublishSeverals() {
    
    for i in 0...self.recursiveLimit {
      for j in 0...self.recursiveLimit {
        self.X_hub.X_subscribeNotificationForName(String(j), sender: nil) { not in}
      }
    }
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        self.X_hub.X_publishNotificationName(String(i))
      }
      return
    }
    
  }
  
  func testPublishSeverals() {
    
    for i in 0...self.recursiveLimit {
      for j in 0...self.recursiveLimit {
        self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
      }
    }
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        self.hub.publishNotificationName(String(i))
      }
      return
    }
    
  }


  func testApplePublishSeverals() {
    
    for i in 0...self.recursiveLimit {
      for j in 0...self.recursiveLimit {
        self.center.addObserverForName(String(j), object: nil, queue: nil) { not in }
      }
    }
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        self.center.postNotificationName(String(i), object: nil, userInfo:nil)
      }
      return
    }
    
  }
  
  



}
