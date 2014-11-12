//
//  SpriteKitCompositionTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 15/09/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import XCTest


class NotificationHubDefaultTests: XCTestCase {
  var hub = NotificationHub<[String:Any]>()
  let notificationName = "notificationName"
  var notificationUserInfo = [String:Any]()
  
  override func setUp() {
    super.setUp()
    self.notificationUserInfo["key"] = 5
    var hub = NotificationHub<[String:Any]>()
  }
    
  override func tearDown() {
    super.tearDown()
  }

  
  func testDefaultNotificationHub() {
    XCTAssert(NotificationHubDefault === NotificationHubDefault)
    XCTAssertNotNil(NotificationHubDefault)
  }
  
  func testCreateNotificationHub() {
    var hub = NotificationHub<[String:String]>()
    XCTAssertFalse(self.hub === hub)
    XCTAssertNotNil(hub)
  }
  
  func testAddDefaultNotification() {
    var notification = self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
    }
    XCTAssertNotNil(notification)
    XCTAssertEqual(self.notificationName, notification.name)
    XCTAssertNil(notification.sender)
    XCTAssertTrue(notification.userInfo == nil)
    
  }
  

  func testPostDefaultSenderLessNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)

    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    self.waitForExpectationsWithTimeout(1, nil)
    
    XCTAssertTrue(didPublish)

    
  }
  
  func testPostDefaultSenderLessNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssertEqual(self, notification.sender! as NotificationHubDefaultTests)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,nil)
    
    XCTAssertTrue(didPublish)
    
  }

  func testPostDefaultNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isNotPublished = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isNotPublished = false
    }
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if isNotPublished { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1,nil)
    
    XCTAssertFalse(didPublish)
  }
  
  func testPostDefaultNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)

    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()

    }
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,nil)
    
    XCTAssertTrue(didPublish)

  }
  
  func testPostTwoDefaultNotificationWithSender() {

    let expectationFirst = self.expectationWithDescription(self.notificationName)
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectationFirst.fulfill()
      
    }
    
    let expectationSecond = self.expectationWithDescription(self.notificationName)
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectationSecond.fulfill()
      
    }

    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,nil)
    
    XCTAssertTrue(didPublish)
    
  }

  
  func testPostDefaultNotification() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    let notification = self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
      
    }
    let didPublish = self.hub.publishNotification(notification)
    self.waitForExpectationsWithTimeout(1,nil)
    
    XCTAssertTrue(didPublish)
    
  }

  func testRemoveDefaultSenderLessNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }
    let didRemove = self.hub.removeNotificationsName(self.notificationName, sender: nil)
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublish)

    
  }

  
  func testRemoveDefaultSenderLessNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }
    let didRemove = self.hub.removeNotificationsName(self.notificationName, sender: self)
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublish)

    
  }

  func testRemoveDefaultNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = false
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = true
    }
    let didRemove  = self.hub.removeNotificationsName(self.notificationName, sender: nil)
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    if isRemoved  { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
    XCTAssertFalse(didRemove)
    XCTAssertTrue(didPublish)

    
  }
  
  
  func testRemoveDefaultNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }
    let didRemove  = self.hub.removeNotificationsName(self.notificationName, sender: self)
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublish)

    
  }

  func testRemoveNotificationsWithName() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }
    let didRemove  = self.hub.removeNotificationsName(self.notificationName, sender: self)
    let didPublish = self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublish)

    
  }
  
  func testRemoveAllNotificationsWithName() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }
    
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }

    let didRemove             = self.hub.removeAllNotificationsName(self.notificationName)
    let didPublishWithSelf    = self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    let didPublishWithOutSelf = self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    
    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublishWithSelf)
    XCTAssertFalse(didPublishWithOutSelf)
    XCTAssertFalse(self.hub.removeAllNotificationsName(self.notificationName))
    
  }

  
  func testRemoveAllNotifications() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var isRemoved = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      isRemoved = false
    }
    
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      isRemoved = false
    }

    self.hub.subscribeNotificationForName("Testing something", sender: nil) { notification in
      isRemoved = false
    }

    let didRemove               = self.hub.removeAllNotifications()
    let didPublishWithSelf      = self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    let didPublishWithOutSelf   = self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    let didPublishDifferentName = self.hub.publishNotificationName("Testing something", sender: nil, userInfo: nil)
    
    if isRemoved { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublishWithSelf)
    XCTAssertFalse(didPublishWithOutSelf)
    XCTAssertFalse(didPublishDifferentName)
    XCTAssertFalse(self.hub.removeAllNotifications())
    
  }

  
  func testPostWithUserInfo() {
    let expectation = self.expectationWithDescription(self.notificationName)

    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { n in
      let value = n.userInfo!["key"] as Int
      let expectedValue = self.notificationUserInfo["key"] as Int
      XCTAssertEqual(value, expectedValue)
      XCTAssertNotNil(value)
      expectation.fulfill()
    }
   let didPublish = self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: self.notificationUserInfo)
   self.waitForExpectationsWithTimeout(1, nil)

    XCTAssertTrue(didPublish)

  }

  


}
