//
//  SpriteKitCompositionTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 15/09/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import XCTest


class NotificationHubDefaultTests: XCTestCase {
  let notificationName = "notificationName"
  var notificationUserInfo = [String:Any]()
  
  override func setUp() {
    super.setUp()
    self.notificationUserInfo["key"] = 5
  }
    
  override func tearDown() {
    super.tearDown()
    NotificationHubDefault.removeAllNotifications()
    
  }

  
  func testDefaultNotificationHub() {
    XCTAssert(NotificationHubDefault === NotificationHubDefault)
    XCTAssertNotNil(NotificationHubDefault)
  }
  
  func testCreateNotificationHub() {
    let hub = NotificationHub<[String:String]>()
    XCTAssertFalse(NotificationHubDefault === hub)
    XCTAssertNotNil(hub)
  }
  
  func testFetchingNotifications() {
    let expectation = self.expectation(description: self.notificationName)
    
    let not = Notification<[String:Any]>(name: self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
      
    }
    NotificationHubDefault.subscribeNotification(not)
    let notification = NotificationHubDefault.notifications[self.notificationName]!.first!
    NotificationHubDefault.publishNotification(notification)
    self.waitForExpectations(timeout: 1,handler: nil)
    
  }
  
  func testSubscribeNotification() {
    let expectation = self.expectation(description: self.notificationName)
    
    let not = Notification<[String:Any]>(name: self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
      
    }
    var didPublish = NotificationHubDefault.publishNotification(not)
    XCTAssertFalse(didPublish)
    
    let notification = NotificationHubDefault.subscribeNotification(not)
    XCTAssertEqual(not, notification)
    didPublish = NotificationHubDefault.publishNotification(not)
    self.waitForExpectations(timeout: 1,handler: nil)
    
  }

  func testSubscribeNotificationShouldChangeHub() {
    let expectation = self.expectation(description: self.notificationName)
    let hub = NotificationHub<[String:Any]>()
    let not = Notification<[String:Any]>(name: self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
      
    }
    
    let notification = hub.subscribeNotification(not)
    var didPublish = NotificationHubDefault.publishNotification(not)
    XCTAssertFalse(didPublish)
    
    let notificationInDefaultHub = NotificationHubDefault.subscribeNotification(notification)
    XCTAssertEqual(notificationInDefaultHub, notification)
    didPublish = NotificationHubDefault.publishNotification(not)
    XCTAssertTrue(didPublish)


    self.waitForExpectations(timeout: 1,handler: nil)
    
  }

  
  func testSubscribeWithoutSender() {
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
    }
    XCTAssertNotNil(notification)
    XCTAssertEqual(self.notificationName, notification.name)
    XCTAssertNil(notification.sender)
    XCTAssertTrue(notification.userInfo == nil)
    
  }
  

  func testPublishWithoutSender() {
    let expectation = self.expectation(description: self.notificationName)

    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    let didPublish = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: nil, userInfo: nil)
    self.waitForExpectations(timeout: 1, handler: nil)
    
    XCTAssertTrue(didPublish)

    
  }
  
  func testPublishWithSenderSubscribeWithoutSender() {
    let expectation = self.expectation(description: self.notificationName)
    
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssertEqual(self, notification.sender! as? NotificationHubDefaultTests)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    let didPublish = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectations(timeout: 1,handler: nil)
    
    XCTAssertTrue(didPublish)
    
  }

  func testPublishWithoutSenderSubscribeWithSender() {
    let expectation = self.expectation(description: self.notificationName)
    
    var isNotPublished = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isNotPublished = false
    }
    let didPublish = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: nil, userInfo: nil)
    if isNotPublished { expectation.fulfill() }
    self.waitForExpectations(timeout: 1,handler: nil)
    
    XCTAssertFalse(didPublish)
  }
  
  func testPublishWithSender() {
    let expectation = self.expectation(description: self.notificationName)

    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()

    }
    let didPublish = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectations(timeout: 1,handler: nil)
    
    XCTAssertTrue(didPublish)

  }
  
  func testPublishWithSenderAndWithoutSender() {

    let expectationFirst = self.expectation(description: self.notificationName)
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectationFirst.fulfill()
      
    }
    
    let expectationSecond = self.expectation(description: self.notificationName)
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectationSecond.fulfill()
      
    }

    let didPublish = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectations(timeout: 1,handler: nil)
    
    XCTAssertTrue(didPublish)
    
  }

  
  func testPublishNotification() {
    let expectation = self.expectation(description: self.notificationName)
    
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
      
    }
    let didPublish = NotificationHubDefault.publishNotification(notification)
    self.waitForExpectations(timeout: 1,handler: nil)
    
    XCTAssertTrue(didPublish)
    
  }
  
  func testPublishNotificationWithoutSubscribe() {
    let expectation = self.expectation(description: self.notificationName)
    
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
      
    }
    let didPublish = NotificationHubDefault.publishNotification(notification)
    self.waitForExpectations(timeout: 1,handler: nil)
    
    XCTAssertTrue(didPublish)
    
  }

  func testRemoveWithoutSender() {
    let expectation = self.expectation(description: self.notificationName)
    
    var isRemoved = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }

    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove = NotificationHubDefault.removeNotificationsName(self.notificationName, sender: nil)
    for notification in notifications {
      let didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }
    
    
    if isRemoved { expectation.fulfill() }
    self.waitForExpectations(timeout: 1, handler: nil)
    
    XCTAssertTrue(didRemove)

    
  }

  
  func testRemoveWithSender() {
    let expectation = self.expectation(description: self.notificationName)
    
    var isRemoved = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }
    
    
    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove = NotificationHubDefault.removeNotificationsName(self.notificationName, sender: self)
    for notification in notifications {
      let didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }

    if isRemoved { expectation.fulfill() }
    self.waitForExpectations(timeout: 1, handler: nil)
    
    XCTAssertTrue(didRemove)


    
  }

  func testRemoveWithoutSenderSubscribedWithSender() {
    let expectation = self.expectation(description: self.notificationName)
    
    var isRemoved = false
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = true
    }

    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove  = NotificationHubDefault.removeNotificationsName(self.notificationName, sender: nil)
    for notification in notifications {
      let didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertTrue(didPublish)
    }

    if isRemoved  { expectation.fulfill() }
    self.waitForExpectations(timeout: 1, handler: nil)
    
    XCTAssertFalse(didRemove)

    
  }
  
  
  func testRemoveWithSenderSubscribedWithSender() {
    let expectation = self.expectation(description: self.notificationName)
    
    var isRemoved = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }

    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove  = NotificationHubDefault.removeNotificationsName(self.notificationName, sender: self)
    for notification in notifications {
      let didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }

    if isRemoved { expectation.fulfill() }
    self.waitForExpectations(timeout: 1, handler: nil)
    
    XCTAssertTrue(didRemove)

  }
  
  
  func testRemoveAllSender() {
    let expectation = self.expectation(description: self.notificationName)
    
    var isRemoved = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }

    NotificationHubDefault.subscribeNotificationForName("crap", sender: self) { notification in
      isRemoved = false
    }

    NotificationHubDefault.subscribeNotificationForName("Fuck", sender: self) { notification in
      isRemoved = false
    }

    var notifications = NotificationHubDefault.notifications[self.notificationName]!
    notifications.append(NotificationHubDefault.notifications["crap"]!.first!)
    notifications.append(NotificationHubDefault.notifications["Fuck"]!.first!)
    let didRemove  = NotificationHubDefault.removeAllNotificationsSender(sender: self)
    for notification in notifications {
      let didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }
    
    if isRemoved { expectation.fulfill() }
    self.waitForExpectations(timeout: 1, handler: nil)
    
    XCTAssertTrue(didRemove)
    
  }

  
  func testRemoveAllNotificationsWithName() {
    let expectation = self.expectation(description: self.notificationName)
    
    var isRemoved = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }
    
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }

    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove             = NotificationHubDefault.removeAllNotificationsName(name: self.notificationName)
    let didPublishWithSelf    = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: self, userInfo: nil)
    let didPublishWithOutSelf = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: nil, userInfo: nil)
    
    for notification in notifications {
      let didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }

    
    if isRemoved { expectation.fulfill() }
    self.waitForExpectations(timeout: 1, handler: nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublishWithSelf)
    XCTAssertFalse(didPublishWithOutSelf)
    XCTAssertFalse(NotificationHubDefault.removeAllNotificationsName(name: self.notificationName))
    
  }

  
  func testRemoveAllNotifications() {
    let expectation = self.expectation(description: self.notificationName)
    
    var isRemoved = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }
    
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }

    NotificationHubDefault.subscribeNotificationForName("Testing something", sender: nil) { notification in
      isRemoved = false
    }

    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove               = NotificationHubDefault.removeAllNotifications()
    let didPublishWithSelf      = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: self, userInfo: nil)
    let didPublishWithOutSelf   = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: nil, userInfo: nil)
    let didPublishDifferentName = NotificationHubDefault.publishNotificationName(name: "Testing something", sender: nil, userInfo: nil)
    
    for notification in notifications {
      let didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }

    if isRemoved { expectation.fulfill() }
    self.waitForExpectations(timeout: 1, handler: nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublishWithSelf)
    XCTAssertFalse(didPublishWithOutSelf)
    XCTAssertFalse(didPublishDifferentName)
    XCTAssertFalse(NotificationHubDefault.removeAllNotifications())
    XCTAssertTrue(NotificationHubDefault.notifications.isEmpty)
    
  }

  
  func testPostWithUserInfo() {
    let expectation = self.expectation(description: self.notificationName)

    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { n in
      let value = n.userInfo!["key"] as! Int
      let expectedValue = self.notificationUserInfo["key"] as! Int
      XCTAssertEqual(value, expectedValue)
      XCTAssertNotNil(value)
      expectation.fulfill()
    }
    let didPublish = NotificationHubDefault.publishNotificationName(name: self.notificationName, sender: nil, userInfo: self.notificationUserInfo)
   self.waitForExpectations(timeout: 1, handler: nil)

    XCTAssertTrue(didPublish)

  }

  


}
