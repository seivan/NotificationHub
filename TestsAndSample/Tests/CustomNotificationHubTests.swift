//
//  CustomNotificationHubTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 03/11/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import XCTest

class CustomNotificationHubTests: XCTestCase {
  let hub = NotificationHub<(string: String, int: Int)>()
  let notificationName = "notificationName"
  
  
  func testPublish() {
    let expectation = self.expectationWithDescription(self.notificationName)
    let notification = self.hub.subscribeNotificationForName(self.notificationName, sender: nil) { not in
      let string = not.userInfo?.string as String?
      let int = not.userInfo?.int as Int?
      XCTAssertEqual(string!, "LOL")
      XCTAssertEqual(int!, 5)
      expectation.fulfill()
    }
    self.hub.publishNotificationName(self.notificationName, sender: nil, userInfo: (string: "LOL", int:5))
    self.waitForExpectationsWithTimeout(1.0, nil)
    XCTAssertTrue(notification.userInfo == nil)
  }
  
  

}
