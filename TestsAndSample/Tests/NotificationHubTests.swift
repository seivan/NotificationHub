//
//  SpriteKitCompositionTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 15/09/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import XCTest


class NotificationHubTests: XCTestCase {
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

  }
  
  func testAddDefaultNotification() {
    var notification = self.hub.addObserverForName(self.notificationName, sender: nil) { notification in
    }
    XCTAssertNotNil(notification)
    XCTAssertEqual(self.notificationName, notification.name)
    XCTAssertNil(notification.sender)
    XCTAssertTrue(notification.userInfo == nil)
    
  }
  

  func testPostDefaultSenderLessNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)

    self.hub.addObserverForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    self.hub.postNotificationName(self.notificationName, sender: nil, userInfo: nil)
    self.waitForExpectationsWithTimeout(1, nil)
    
  }
  
  func testPostDefaultSenderLessNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    self.hub.addObserverForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    self.hub.postNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,nil)
    
  }

  func testPostDefaultNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didNotCall = true
    self.hub.addObserverForName(self.notificationName, sender: self) { notification in
      didNotCall = false
    }
    self.hub.postNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if didNotCall { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1,nil)
  }
  
  func testPostDefaultNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)

    self.hub.addObserverForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()

    }
    self.hub.postNotificationName(self.notificationName, sender: self, userInfo: nil)
    self.waitForExpectationsWithTimeout(1,nil)

  }
  
  func testPostDefaultNotification() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    let notification = self.hub.addObserverForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNotNil(notification.sender)
      XCTAssert(self === notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
      
    }
    self.hub.postNotification(notification)
    self.waitForExpectationsWithTimeout(1,nil)
    
  }

  func testRemoveDefaultSenderLessNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didRemove = true
    self.hub.addObserverForName(self.notificationName, sender: nil) { notification in
      didRemove = false
    }
    self.hub.removeNotification(self.notificationName, sender: nil)
    self.hub.postNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if didRemove { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }

  
  func testRemoveDefaultSenderLessNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didRemove = true
    self.hub.addObserverForName(self.notificationName, sender: nil) { notification in
      didRemove = false
    }
    self.hub.removeNotification(self.notificationName, sender: self)
    self.hub.postNotificationName(self.notificationName, sender: nil, userInfo: nil)
    if didRemove { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }

  func testRemoveDefaultNotificationWithoutSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didNotRemove = false
    self.hub.addObserverForName(self.notificationName, sender: self) { notification in
      didNotRemove = true
    }
    self.hub.removeNotification(self.notificationName, sender: nil)
    self.hub.postNotificationName(self.notificationName, sender: self, userInfo: nil)
    if didNotRemove  { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }
  
  
  func testRemoveDefaultNotificationWithSender() {
    let expectation = self.expectationWithDescription(self.notificationName)
    
    var didRemove = true
    self.hub.addObserverForName(self.notificationName, sender: self) { notification in
      didRemove = false
    }
    self.hub.removeNotification(self.notificationName, sender: self)
    self.hub.postNotificationName(self.notificationName, sender: self, userInfo: nil)
    if didRemove { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
  }

  


}
