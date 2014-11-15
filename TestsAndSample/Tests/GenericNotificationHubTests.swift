//
//  GenericNotificationHubTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 15/11/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//

import XCTest

class GenericNotificationHubTests: XCTestCase {
  let notificationName = "notificationName"
  var notificationUserInfo = [String:Any]()

  func testSubscribe() {
    let notification = NotificationCenter.defaultHub.subscribeNotificationForName(self.notificationName, sender: nil, type: [String:[Int]].self) { not in
      println(not.userInfo)
      println("BOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
    }
    
    NotificationCenter.defaultHub.publishNotificationName(self.notificationName, sender: nil, userInfo: ["Hey" : [12,3,4]])
    
  }

}
