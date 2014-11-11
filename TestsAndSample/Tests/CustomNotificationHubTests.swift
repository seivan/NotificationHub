//
//  CustomNotificationHubTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 03/11/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import XCTest

class CustomNotificationHubTests: XCTestCase {
  let notificationName = "notificationName"
  var hub = NotificationHub<(string: String, int: Int)>()
  var counter = 0
  
  override func setUp() {
    super.setUp()
    self.hub = NotificationHub<(string: String, int: Int)>()
  }
  
  func subscribe(notificationName:String = "notificationName", sender:AnyObject? = nil, block:(@autoclosure () -> ())? = nil) -> Notification<(string: String, int: Int)>  {
    return self.hub.subscribeNotificationForName(notificationName, sender: sender) { not in
      if(block != nil) { block!() }
    }
  }
  
  func publish(notificationName:String = "notificationName", sender:AnyObject? = nil, userInfo:(string: String, int: Int)? = (string: "LOL", int:5) ) -> Bool {
    let didPublish = self.hub.publishNotificationName(notificationName, sender: sender, userInfo: userInfo)
    return didPublish
  }
  
  
  func testPublish() {
    let expectation = self.expectationWithDescription(self.notificationName)
    let notification = self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { not in
      let string = not.userInfo?.string as String?
      let int = not.userInfo?.int as Int?
      XCTAssertEqual(string!, "LOL")
      XCTAssertEqual(int!, 5)
      expectation.fulfill()
    }
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: (string: "LOL", int:5))
    self.waitForExpectationsWithTimeout(1.0, nil)
    XCTAssertTrue(notification.userInfo == nil)
    XCTAssertTrue(didPublish)
  }

  func testRemoveWithName() {
    self.subscribe()
    let didRemove = self.hub.removeNotificationsName(self.notificationName, sender: self)
    let didPublish = self.publish()
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublish)
    
  }

  func testRemoveNotification() {
    let notification = self.subscribe()
    let didRemove = self.hub.removeNotification(notification)
    let didPublish = self.publish()
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublish)
    
  }

  func testRemoveAllNotifications() {
    self.subscribe()
    let didRemove = self.hub.removeAllNotifications()
    let didPublish = self.publish()
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublish)
  }
  
  func subscribeAndResetCounter() {
    self.counter = 0
    for i in 0..<100 {
      self.subscribe(notificationName: String(i), block:self.counter += 1 )
      self.subscribe(notificationName: String(i), sender:self, block: self.counter += 1 )
    }

  }
  
  func testPublishSeveralNotificationsWithoutSender() {
    self.subscribeAndResetCounter()
    for name in 0..<100 { self.publish(notificationName: String(name)) }
    XCTAssertEqual(self.counter, 100)
  }
  
  func testPublishSeveralNotificationsWithSender() {
    self.subscribeAndResetCounter()
    for name in 0..<100 { self.publish(notificationName: String(name), sender:self) }
    XCTAssertEqual(self.counter, 200)
  }

  func testRemoveNotifications() {
    self.subscribeAndResetCounter()
    for i in 0..<100 { self.hub.removeNotificationsName(String(i), sender: nil) }
    for i in 0..<100 { self.publish(notificationName: String(i), sender:self) }
    XCTAssertEqual(self.counter, 100)
  }

  func testRemoveNotificationsSender() {
    self.subscribeAndResetCounter()
    for i in 0..<100 { self.hub.removeNotificationsName(String(i), sender: self) }
    for i in 0..<100 { self.publish(notificationName: String(i), sender:self) }
    XCTAssertEqual(self.counter, 100)
  }

  
//    for name in 0..<100 {
//      self.publish(name: String(name))
//    }
//    XCTAssertEqual(counter, 100)
//
//    
//    for name in 0..<100 {
//      self.hub.removeNotificationsName(String(name), sender: self)
//    }
//
//    counter = 0
//    for name in 0..<100 {
//      self.publish(name: String(name))
//    }
//
//    XCTAssertEqual(counter, 100)
//    
//    let didRemove = self.hub.removeAllNotifications()

  


}
