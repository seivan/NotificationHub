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
    self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    self.waitForExpectationsWithTimeout(1, nil)
    
  }
  
  func testPostDefaultSenderLessNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,nil)
    
  }

  func testPostDefaultNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didNotCall = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      didNotCall = false
    }
    self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if didNotCall { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1,nil)
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
    self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,nil)

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
    self.hub.publishNotification(notification)
    self.waitForExpectationsWithTimeout(1,nil)
    
  }

  func testRemoveDefaultSenderLessNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didRemove = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      didRemove = false
    }
    self.hub.removeNotificationsName(self.notificationName, sender: nil)
    self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if didRemove { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }

  
  func testRemoveDefaultSenderLessNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didRemove = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      didRemove = false
    }
    self.hub.removeNotificationsName(self.notificationName, sender: self)
    self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if didRemove { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }

  func testRemoveDefaultNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didNotRemove = false
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      didNotRemove = true
    }
    self.hub.removeNotificationsName(self.notificationName, sender: nil)
    self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    if didNotRemove  { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }
  
  
  func testRemoveDefaultNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didRemove = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      didRemove = false
    }
    self.hub.removeNotificationsName(self.notificationName, sender: self)
    self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    if didRemove { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }

  func testRemoveNotificationsWithName() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didRemove = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      didRemove = false
    }
    self.hub.removeNotificationsName(self.notificationName, sender: self)
    self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    if didRemove { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }
  
  func testRemoveAllNotificationsWithName() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didRemove = true
    self.hub.subscribeNotificationForName(self.notificationName, sender: self) { notification in
      didRemove = false
    }
    
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { notification in
      didRemove = false
    }

    self.hub.removeAllNotificationsName(self.notificationName)
    self.hub.publishNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: nil)
    
    if didRemove { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }

  
  func testPostWithUserInfo() {
    self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { n in
      let value = n.userInfo!["key"] as Int
      let expectedValue = self.notificationUserInfo["key"] as Int
      XCTAssertEqual(value, expectedValue)
      XCTAssertNotNil(value)
      
    }
    self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: self.notificationUserInfo)

  }

  


}
