//
//  SpriteKitCompositionTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 15/09/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import UIKit
import XCTest


class NotificationTests: XCTestCase {
  let hub = NotificationHubDefault
  let notificationName = "notificationName"
  var notificationUserInfo = [String:Any]()
  override func setUp() {
    super.setUp()
    self.notificationUserInfo["key"] = 5
  }
    
  override func tearDown() {
    super.tearDown()
  }
  
  func testDefaultHub() {
    XCTAssertNotNil(self.hub)
    XCTAssertTrue(self.hub === NotificationHubDefault)
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
  

  func testPostDefaultNotificationWithoutSender() {
    let expectation = expectationWithDescription(self.notificationName)

    NotificationHubDefault.addObserverForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
   }
    self.hub.postNotificationName(self.notificationName, sender: nil, userInfo: nil)
    
    
    var didCallNotification = false
    NotificationHubDefault.addObserverForName(self.notificationName, sender: self) { notification in
      didCallNotification = true
    }
    
    self.hub.postNotificationName(self.notificationName, sender: nil, userInfo: nil)
    XCTAssertFalse(didCallNotification)

  }

  func testPostDefaultNotificationWithSender() {
    let expectation = expectationWithDescription(self.notificationName)
    
    NotificationHubDefault.addObserverForName(self.notificationName, sender: self) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    self.hub.postNotificationName(self.notificationName, sender: self, userInfo: nil)
    
    var didCallNotification = false
    NotificationHubDefault.addObserverForName(self.notificationName, sender: nil) { notification in
      didCallNotification = true
    }
    
    self.hub.postNotificationName(self.notificationName, sender: self, userInfo: nil)
    XCTAssertFalse(didCallNotification)

  }

  func testPostDefaultNotificationWithNotification() {
    let expectation = expectationWithDescription(self.notificationName)
    
   let notification = NotificationHubDefault.addObserverForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo == nil)
      expectation.fulfill()
    }
    self.hub.postNotification(notification)
  }

  func testPostDefaultNotificationWithUserInfo() {
    let expectation = expectationWithDescription(self.notificationName)
    
    let notification = NotificationHubDefault.addObserverForName(self.notificationName, sender: nil) { notification in
      XCTAssertNotNil(notification)
      XCTAssertEqual(self.notificationName, notification.name)
      XCTAssertNil(notification.sender)
      XCTAssertTrue(notification.userInfo != nil)
//      let list = notification.userInfo?["Key"] as [Any]
//      XCTAssertEqual(list.count, 1)
//
//      expectation.fulfill()
    }
    XCTAssertTrue(notification.userInfo == nil)
    XCTAssertEqual(self.notificationUserInfo.count, 1)
    
    self.hub.postNotificationName(
      self.notificationName,
      sender: nil,
      userInfo: self.notificationUserInfo)
  }

  
  

}
