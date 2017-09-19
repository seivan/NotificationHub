//
//  PerformanceTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 04/10/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//


import XCTest

class PerformanceTests: XCTestCase {

  var hub = NotificationHub<[String:String]>()
  var center = NotificationCenter()
  let recursiveLimit = 100 //30*30 = 900
  
  override func setUp() {
    super.setUp()
    self.hub = NotificationHub<[String:String]>()
    self.center = NotificationCenter()

  }
  
 
  /**************************************************************************
  SUBSCRIBE
  ***************************************************************************/
  func testSubscribe() {
    self.measure() { for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
      }}; return }}
  
  
  func testAppleSubscribe() {
    self.measure() {
      for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
        self.center.addObserver(forName: NSNotification.Name(String(j)), object: nil, queue: nil) { not in }
        }}; return }}
  /**************************************************************************
  PUBLISH
  ***************************************************************************/
  func testPublish() {
    for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
        self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
      }}
    
    self.measure() {
      for i in 0...self.recursiveLimit {
        self.hub.publishNotificationName(name: String(i))
      }; return }
  }


  func testApplePublish() {
    for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
        self.center.addObserver(forName: NSNotification.Name(String(j)), object: nil, queue: nil) { not in }
      }}
    
    self.measure() {
      for i in 0...self.recursiveLimit {
        self.center.post(name: NSNotification.Name(String(i)), object: nil)
      }; return }
  }
  
  
  
  /**************************************************************************
  REMOVE
  ***************************************************************************/
  func testRemoveNotifications() {
    var observers = [Notification<[String : String]>]()
    for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      observers.append(self.hub.subscribeNotificationForName(String(j), sender: nil) { not in})
      }}
    
    self.measure() {
      for observer in observers {
        self.hub.removeNotification(observer)
      }; return }
  }

  func testRemoveNotificationWithName() {
    for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
      }}
    
    self.measure() {
      for i in 0...self.recursiveLimit {
        self.hub.removeNotificationsName(String(i), sender: nil)
      }; return }
  }

  func testRemoveNotificationWithNameSender() {
    for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      self.hub.subscribeNotificationForName(String(j), sender: nil) { not in}
      }}
    
    self.measure() {
      for i in 0...self.recursiveLimit {
        self.hub.removeNotificationsName(String(i), sender: self)
      }; return }
  }

  func testRemoveAllSender() {
    for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      self.hub.subscribeNotificationForName(String(j), sender: self) { not in}
      }}
    
    self.measure() {
        self.hub.removeAllNotificationsSender(sender:self)
      return
    }
  }
  
  func testRemoveAll() {
    for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      self.hub.subscribeNotificationForName(String(j), sender: self) { not in}
      }}
    
    self.measure() {
      self.hub.removeAllNotifications()
      return
    }
  }
  
  func testAppleRemove() {
    var observers = [NSObjectProtocol]()
    for _ in 0...self.recursiveLimit { for j in 0...self.recursiveLimit {
      
        observers.append(self.center.addObserver(forName: NSNotification.Name(String(j)), object: nil, queue: nil) { not in })
      }}
    
    self.measure() {
      for observer in observers {
        self.center.removeObserver(observer)
      }; return }
  }


}

