//
//  NotificationTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 03/11/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//


import XCTest

class NotificationTests: XCTestCase {
  let notificationName = "notificationName"

  func testName() {
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { not in
      
    }

    XCTAssertEqual(notification.name, self.notificationName)
  }

  func testSenderNil() {
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: nil) { not in
      
    }

    XCTAssertNil(notification.sender)
  }

  func testSender() {
    var notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { not in
      
    }
    XCTAssertNotNil(notification.sender)
    let test = notification.sender as NotificationTests
    XCTAssertEqual(test, self)
  }
  
  func testUserInfo() {
    var notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { not in
      
    }
    XCTAssertTrue(notification.userInfo == nil)

  }

  func testPublishUserInfo() {
    let expectation = self.expectationWithDescription(self.notificationName)
    var notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { not in
      let value = not.userInfo!["key"] as Int
      XCTAssertEqual(value, 5)
      XCTAssertNotNil(value)
      expectation.fulfill()

    }
    
    let didPublish = notification.publishUserInfo(["key" : 5])
    XCTAssertTrue(didPublish)
    
    self.waitForExpectationsWithTimeout(1, nil)
    XCTAssertTrue(notification.userInfo == nil)
  }
  
  func testRemove() {
    let hub = NotificationHub<String>()
    let expectation = self.expectationWithDescription(self.notificationName)
    var isRemoved = true

    var notification = hub.subscribeNotificationForName(self.notificationName, sender: self) { not in
        isRemoved = false
    }

    XCTAssertEqual(notification.sender as NotificationTests, self)
    
    let didRemove      = notification.remove()
    let didPublish     = notification.publishUserInfo(nil)
    let didRemoveAgain = hub.removeAllNotifications()
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublish)
    XCTAssertTrue(notification.userInfo == nil)
    XCTAssertNil(notification.sender)
    XCTAssertFalse(didRemoveAgain)
    
    if(isRemoved) { expectation.fulfill() }
    self.waitForExpectationsWithTimeout(1, nil)
    
    
  }

  


}
