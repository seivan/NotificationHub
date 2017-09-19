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

  func testInit() {
    let notification = Notification<String>(name: self.notificationName, sender: self) { not in
      
    }
    XCTAssertEqual(self.notificationName, notification.name)
    XCTAssertTrue(self === notification.sender)
    XCTAssertNil(notification.userInfo)
  }
  

  
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
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { not in
      
    }
    XCTAssertNotNil(notification.sender)
    let test = notification.sender as! NotificationTests
    XCTAssertEqual(test, self)
  }
  
  func testUserInfo() {
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { not in
      
    }
    XCTAssertTrue(notification.userInfo == nil)

  }

  func testPublishUserInfo() {
    let expectation = self.expectation(description: self.notificationName)
    let notification = NotificationHubDefault.subscribeNotificationForName(self.notificationName, sender: self) { not in
      let value = not.userInfo!["key"] as! Int
      XCTAssertEqual(value, 5)
      XCTAssertNotNil(value)
      expectation.fulfill()

    }
    
    let didPublish = notification.publishUserInfo(["key" : 5])
    XCTAssertTrue(didPublish)
    
    self.waitForExpectations(timeout:1, handler: nil)
    XCTAssertTrue(notification.userInfo == nil)
  }
  
  func testRemove() {
    let hub = NotificationHub<String>()
    let expectation = self.expectation(description: self.notificationName)
    var isRemoved = true

    let notification = hub.subscribeNotificationForName(self.notificationName, sender: self) { not in
        isRemoved = false
    }

    XCTAssertEqual(notification.sender as? NotificationTests, self)
    
    let didRemove      = notification.remove()
    let didPublish     = notification.publishUserInfo(nil)
    let didRemoveAgain = hub.removeAllNotifications()
    
    XCTAssertTrue(didRemove)
    XCTAssertFalse(didPublish)
    XCTAssertTrue(notification.userInfo == nil)
    XCTAssertNotNil(notification.sender)
    XCTAssertFalse(didRemoveAgain)
    
    if(isRemoved) { expectation.fulfill() }
    self.waitForExpectations(timeout: 1, handler: nil)
    
    
  }
  

  


}
