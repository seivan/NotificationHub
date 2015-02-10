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
    var hub = NotificationHub<[String:String]>()
    XCTAssertFalse(NotificationHubDefault === hub)
    XCTAssertNotNil(hub)
  }
  
  func testFetchingNotifications() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
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
    self.waitForExpectationsWithTimeout(1,handler: nil)
    
  }
  
  func testSubscribeNotification() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
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
    self.waitForExpectationsWithTimeout(1,handler: nil)
    
  }

  func testSubscribeNotificationShouldChangeHub() {
    let expectation = self.expectationWithDescription(self.notificationName)
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


    self.waitForExpectationsWithTimeout(1,handler: nil)
    
  }

  
  func testSubscribeWithoutSender() {
    var notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
    }
    XCTAssertNotNil(notification)
    XCTAssertEqual(self.notificationName, notification.name)
    XCTAssertNil(notification.sender)
    XCTAssertTrue(notification.userInfo == nil)
    
  }
  

  func testPublishWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)

    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    let didPublish = NotificationHubDefault.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    self.waitForExpectationsWithTimeout(1, handler: nil)
    
    XCTAssertTrue(didPublish)

    
  }
  
  func testPublishWithSenderSubscribeWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssertEqual(self, notification.sender! as! NotificationHubDefaultTests)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    let didPublish = NotificationHubDefault.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,handler: nil)
    
    XCTAssertTrue(didPublish)
    
  }

  func testPublishWithoutSenderSubscribeWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isNotPublished = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isNotPublished = false
    }
    let didPublish = NotificationHubDefault.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if isNotPublished { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1,handler: nil)
    
    XCTAssertFalse(didPublish)
  }
  
  func testPublishWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)

    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()

    }
    let didPublish = NotificationHubDefault.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,handler: nil)
    
    XCTAssertTrue(didPublish)

  }
  
  func testPublishWithSenderAndWithoutSender() {

    let expectationFirst = self.expectationWithDescription(self.notificationName)
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectationFirst.fulfill()
      
    }
    
    let expectationSecond = self.expectationWithDescription(self.notificationName)
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectationSecond.fulfill()
      
    }

    let didPublish = NotificationHubDefault.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,handler: nil)
    
    XCTAssertTrue(didPublish)
    
  }

  
  func testPublishNotification() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
      
    }
    let didPublish = NotificationHubDefault.publishNotification(notification)
    self.waitForExpectationsWithTimeout(1,handler: nil)
    
    XCTAssertTrue(didPublish)
    
  }
  
  func testPublishNotificationWithoutSubscribe() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
      
    }
    let didPublish = NotificationHubDefault.publishNotification(notification)
    self.waitForExpectationsWithTimeout(1,handler: nil)
    
    XCTAssertTrue(didPublish)
    
  }

  func testRemoveWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
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
      var didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }
    
    
    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, handler: nil)
    
    XCTAssertTrue(didRemove)

    
  }

  
  func testRemoveWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }
    
    
    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove = NotificationHubDefault.removeNotificationsName(self.notificationName, sender: self)
    for notification in notifications {
      var didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }

    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, handler: nil)
    
    XCTAssertTrue(didRemove)


    
  }

  func testRemoveWithoutSenderSubscribedWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = false
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = true
    }

    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove  = NotificationHubDefault.removeNotificationsName(self.notificationName, sender: nil)
    for notification in notifications {
      var didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertTrue(didPublish)
    }

    if isRemoved  { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, handler: nil)
    
    XCTAssertFalse(didRemove)

    
  }
  
  
  func testRemoveWithSenderSubscribedWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }

    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove  = NotificationHubDefault.removeNotificationsName(self.notificationName, sender: self)
    for notification in notifications {
      var didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }

    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, handler: nil)
    
    XCTAssertTrue(didRemove)

  }
  
  
  func testRemoveAllSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
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
    let didRemove  = NotificationHubDefault.removeAllNotificationsSender(self)
    for notification in notifications {
      var didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }
    
    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, handler: nil)
    
    XCTAssertTrue(didRemove)
    
  }

  
  func testRemoveAllNotificationsWithName() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = true
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }
    
    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }

    let notifications = NotificationHubDefault.notifications[self.notificationName]!
    let didRemove             = NotificationHubDefault.removeAllNotificationsName(self.notificationName)
    let didPublishWithSelf    = NotificationHubDefault.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    let didPublishWithOutSelf = NotificationHubDefault.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    
    for notification in notifications {
      var didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }

    
    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, handler: nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublishWithSelf)
    XCTAssertFalse(didPublishWithOutSelf)
    XCTAssertFalse(NotificationHubDefault.removeAllNotificationsName(self.notificationName))
    
  }

  
  func testRemoveAllNotifications() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
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
    let didPublishWithSelf      = NotificationHubDefault.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    let didPublishWithOutSelf   = NotificationHubDefault.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    let didPublishDifferentName = NotificationHubDefault.publishNotificationName("Testing something", sender: nil, userInfo: nil)
    
    for notification in notifications {
      var didPublish = NotificationHubDefault.publishNotification(notification)
      XCTAssertFalse(didPublish)
    }

    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, handler: nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublishWithSelf)
    XCTAssertFalse(didPublishWithOutSelf)
    XCTAssertFalse(didPublishDifferentName)
    XCTAssertFalse(NotificationHubDefault.removeAllNotifications())
    XCTAssertTrue(NotificationHubDefault.notifications.isEmpty)
    
  }

  
  func testPostWithUserInfo() {
    let expectation = self.expectationWithDescription(self.notificationName)

    NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { n in
      let value = n.userInfo!["key"] as! Int
      let expectedValue = self.notificationUserInfo["key"] as! Int
      XCTAssertEqual(value, expectedValue)
      XCTAssertNotNil(value)
      expectation.fulfill()
    }
   let didPublish = NotificationHubDefault.publishNotificationName(self.notificationName, sender: nil, userInfo: self.notificationUserInfo)
   self.waitForExpectationsWithTimeout(1, handler: nil)

    XCTAssertTrue(didPublish)

  }

  


}
