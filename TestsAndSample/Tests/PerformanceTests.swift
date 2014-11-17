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
  let recursiveLimit = 30
  
  override func setUp() {
    super.setUp()
    self.X_hub = NotificationHub<[String:String]>()
    self.hub = NotificationHub<[String:String]>()
    self.center = NSNotificationCenter()

  }

  /**************************************************************************
  SUBSCRIBE
  ***************************************************************************/
  
  
  func testSubscribe() {
    self.measureBlock() { for i in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
      }}; return }}
  
  
  func testAppleSubscribe() {
    self.measureBlock() {
      for i in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
        self.center.addObserverForName(String(j), object: nil, queue: nil) { not in }
        }}; return }}

  
  /**************************************************************************
  PUBLISH
  ***************************************************************************/
  
  func testPublish() {
    for i in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
        self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
      }}
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        self.hub.publishNotificationName(String(i))
      }; return }
  }


  func testApplePublish() {
    for i in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
        self.center.addObserverForName(String(j), object: nil, queue: nil) { not in }
      }}
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        self.center.postNotificationName(String(i), object: nil, userInfo:nil)
      }; return }
  }
  
  

  /**************************************************************************
  REMOVE
  ***************************************************************************/
  
  func testRemoveNotifications() {
    var observers = [Notification<[String : String]>]()
    for i in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      observers.append(self.hub.subscribeNotificationForName(String(j), sender: nil) { not in})
      }}
    
    self.measureBlock() {
      for observer in observers {
        self.hub.removeNotification(observer)
      }; return }
  }

  func testRemoveNotificationWithName() {
    for i in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
      }}
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        self.hub.removeNotificationsName(String(i), sender: nil)
      }; return }
  }

  func testRemoveNotificationWithNameSender() {
    for i in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
      }}
    
    self.measureBlock() {
      for i in 0...self.recursiveLimit {
        self.hub.removeNotificationsName(String(i), sender: self)
      }; return }
  }

  
  func testAppleRemove() {
    var observers = [NSObjectProtocol]()
    for i in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      observers.append(self.center.addObserverForName(String(j), object: nil, queue: nil) { not in })
      }}
    
    self.measureBlock() {
      for observer in observers {
        self.center.removeObserver(observer)
      }; return }
  }


}

