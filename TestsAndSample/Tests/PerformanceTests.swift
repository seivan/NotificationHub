//
//  PerformanceTests.swift
//  TestsAndSample
//
//  Created by Seivan Heidari on 04/10/14.
//  Copyright (c) 2014 Seivan Heidari. All rights reserved.
//


import XCTest

//class PerformanceTests: XCTestCase {
//
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//      for i in 0...500 {
//        NotificationHubDefault.subscribeNotificationForName("HI", sender: nil) { not in
//          
//        }
//        NSNotificationCenter.defaultCenter().addObserverForName("HI", object: nil, queue: nil) { not in
//          
//        }
//      }
//
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }
//
//    func testPublish() {
//        // This is an example of a performance test case.
//
//      self.measureBlock() {
//        NotificationHubDefault.publishNotificationName("HI")
//        return
//      }
//      
//    }
//  
//  func testNSPublish() {
//    // This is an example of a performance test case.
//    
//    self.measureBlock() {
//      NSNotificationCenter.defaultCenter().postNotificationName("HI", object: nil)
//      return
//    }
//    
//  }
//
//  
//  func testSubscribe() {
//    // This is an example of a performance test case.
//    
//    self.measureBlock() {
//      for i in 0...1000 {
//        NotificationHubDefault.subscribeNotificationForName("HI", sender: nil) { not in
//          
//        }
//      }
//
//      return
//    }
//    
//  }
//  
//  func testNSSubscribe() {
//    // This is an example of a performance test case.
//
//
//    self.measureBlock() {
//      for i in 0...1000 {
//        NSNotificationCenter.defaultCenter().addObserverForName("HI", object: nil, queue: nil) { not in
//          
//        }
//      }
//      return
//    }
//    
//  }
//
//
//}
