//
//  MockingTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 29/11/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import XCTest

func ==(lhs:(String, AnyObject?), rhs:(String, AnyObject?)) -> Bool {
  return lhs.0 == rhs.0 && lhs.1 === rhs.1
}
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
  
  func testOnSubscribeMock() {
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

}
  