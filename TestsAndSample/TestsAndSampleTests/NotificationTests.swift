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
  let notificationSender = self
  override func setUp() {
    super.setUp()
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
    NotificationHubDefault.addObserverForName(self.notificationName, sender: nil) {
            println($0)
    }
    self.hub.addObserverForName(self.notificationName, sender: nil) {
      println($0)
    }
    
  }
  


}
