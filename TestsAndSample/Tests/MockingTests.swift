//
//  MockingTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 29/11/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import XCTest

var NotificationHubDefault = NotificationHub<[String:Any]>()
class MockingTests: XCTestCase {

  var hub = NotificationHub<String>()
  let sender = self
  override func setUp() {
    super.setUp()
    self.hub = NotificationHub<String>()
  }
  
  override func tearDown() {
    super.tearDown()
    self.hub.removeAllNotifications()
    NotificationHubDefault.removeAllNotifications()
  }
  
  func testOnSubscribingMock() {
    var mocks = [(String, AnyObject?)]()
    NotificationHubMock.onSubscribingMock { (name, sender) in
      mocks.append((name, sender))
    }
    
    let first = NotificationHubDefault.subscribeNotificationForName("A name", sender: self) { n in }
    let second = self.hub.subscribeNotificationForName("the second name", sender: nil) { n in }
    
    XCTAssertEqual(mocks.count, 2)
    XCTAssertEqual(mocks.first!.0, first.name)
    XCTAssertTrue(mocks.first!.1 === first.sender)
    XCTAssertTrue(mocks.first!.1 === self)

    XCTAssertEqual(mocks.last!.0, second.name)
    XCTAssertTrue(mocks.last!.1 === second.sender)
    XCTAssertNil(mocks.last!.1)
  }
  
  func testOnPublishingMock() {
    var mocks = [(String, AnyObject?, Any?)]()
    NotificationHubMock.onPublishingMockHandler { (name, sender, userInfo) in
      mocks.append((name, sender, userInfo))
    }
    
    let first = NotificationHubDefault.subscribeNotificationForName("A name", sender: self) { n in }
    let second = self.hub.subscribeNotificationForName("the second name", sender: nil) { n in }
    
    NotificationHubDefault.publishNotification(first, userInfo: nil)
    self.hub.publishNotification(second, userInfo: second.name)
    
    XCTAssertEqual(mocks.count, 2)
    XCTAssertEqual(mocks.first!.0, first.name)
    XCTAssertTrue(mocks.first!.1 === first.sender)
    XCTAssertTrue(mocks.first!.1 === self)
    XCTAssertTrue(mocks.first!.2 == nil)
    
    XCTAssertEqual(mocks.last!.0, second.name)
    XCTAssertTrue(mocks.last!.1 === second.sender)
    XCTAssertNil(mocks.last!.1)
    
    print(mocks.last, terminator: "")
    XCTAssertEqual((mocks.last!.2 as! String), second.name)

  }
  
  
  func testOnRemovingMock() {
    var mocks = [(String?, AnyObject?)]()
    NotificationHubMock.onRemovingMockHandler { (name, sender) in
      mocks.append((name, sender))
    }
    
    NotificationHubMock.onPublishingMockHandler { (name, sender, userInfo) in
      mocks.append((name, sender))
    }

    let first = NotificationHubDefault.subscribeNotificationForName("A name", sender: self) { n in }
    let second = self.hub.subscribeNotificationForName("the second name", sender: nil) { n in }
    
    
    NotificationHubDefault.removeNotification(first)
    self.hub.removeNotification(second)
    
    
    XCTAssertEqual(mocks.count, 2)
    XCTAssertEqual(mocks.first!.0!, first.name)
    XCTAssertTrue(mocks.first!.1 === first.sender)
    XCTAssertTrue(mocks.first!.1 === self)

    
    XCTAssertEqual(mocks.last!.0!, second.name)
    XCTAssertTrue(mocks.last!.1 === second.sender)
    XCTAssertNil(mocks.last!.1)
    
  }
  
  
  func testOnRemovingNamesMock() {
    var mocks = [(String?, AnyObject?)]()
    NotificationHubMock.onRemovingMockHandler { (name, sender) in
      mocks.append((name, sender))
    }
    
    NotificationHubMock.onPublishingMockHandler { (name, sender, userInfo) in
      mocks.append((name, sender))
    }
    
    let first = NotificationHubDefault.subscribeNotificationForName("A name", sender: self) { n in }
    let second = self.hub.subscribeNotificationForName("the second name", sender: nil) { n in }
    
    
    NotificationHubDefault.removeAllNotificationsName(first.name)
    self.hub.removeAllNotificationsName(second.name)
    
    
    XCTAssertEqual(mocks.count, 2)
    
    XCTAssertEqual(mocks.first!.0!, first.name)
    XCTAssertNil(mocks.first!.1)
    
    XCTAssertEqual(mocks.last!.0!, second.name)
    XCTAssertNil(mocks.last!.1)
    
  }

  
  func testOnRemovingAllMock() {
    var mocks = [(String?, AnyObject?)]()
    NotificationHubMock.onRemovingMockHandler { (name, sender) in
     mocks.append((name, sender))
    }

    NotificationHubDefault.subscribeNotificationForName("A name", sender: self) { n in }
    self.hub.subscribeNotificationForName("the second name", sender: nil) { n in }
    
    NotificationHubDefault.removeAllNotifications()
    XCTAssertEqual(mocks.count, 1)
    XCTAssertNil(mocks.first!.0)
    XCTAssertNil(mocks.first!.1)

    self.hub.removeAllNotifications()
    XCTAssertEqual(mocks.count, 2)
    XCTAssertNil(mocks.last!.0)
    XCTAssertNil(mocks.last!.1)

    
  }


}
  