import Foundation

public class Notification<T>  {
  typealias NotificationClosure = (Notification<T>) -> Void
  let name:String
  private(set) weak var sender:AnyObject?
  private(set) var userInfo:T?
  private let closure:NotificationClosure
  
  
  private weak var hub:NotificationHub<T>?
  
  
  init(name:String, sender:AnyObject?, handler:NotificationClosure) {
    self.name     = name
    self.closure  = handler
    self.sender   = sender
  }
  
  
  final func publishUserInfo(userInfo:T?) -> Bool {
    if(self.hub == nil) { return false }
    self.userInfo = userInfo
    self.closure(self)
    self.userInfo = nil
    return true
  }
  
  final func remove() -> Bool {
    if(self.hub == nil) { return false }
    self.hub?.removeNotification(self)
    self.userInfo = nil
    self.hub = nil
    return true
  }
  
  
}


private struct Static {
  static var hubToken : dispatch_once_t = 0
  static var hub : NotificationHub<[String:Any]>? = nil
}


//public var NotificationHubDefault : NotificationHub<[String:Any]> {
//  return NotificationHub<[String:Any]>()
//}


public class NotificationHub<T>  {
  final private var internalNotifications    =  NSMutableDictionary(capacity: 1000)
  final var notifications:[String: [Notification<T>]] {
    return self.internalNotifications as AnyObject as! [String: [Notification<T>]]
  }
  
  private class var defaultHub:NotificationHub<[String:Any]> {
    dispatch_once(&Static.hubToken) {
      Static.hub = NotificationHub<[String:Any]>()
    }
    return Static.hub!
  }
  
  init() {}
  
  
  func subscribeNotificationForName(name: String, sender: AnyObject? = nil, handler: (Notification<T>) -> Void) -> Notification<T> {    
    let notification = Notification(name: name, sender: sender, handler: handler)
    return self.subscribeNotification(notification)
  }
  
  func subscribeNotification(notification:Notification<T>) -> Notification<T> {
    #if DEBUG
      NotificationHubMock.onSubscribeMockHandler?(name:notification.name,sender:notification.sender)
    #endif
    
    if notification.hub !== nil { notification.hub?.removeNotification(notification) }
    notification.hub = self
    
    let name = notification.name
    if let notifications = self.internalNotifications[notification.name] as? NSMutableArray {
      notifications.addObject(notification)
    }
    else {
      var array = NSMutableArray(capacity: 50)
      array.addObject(notification)
      self.internalNotifications[name] = array
    }
    
    return notification
  }
  
  
  func publishNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) -> Bool {
    #if DEBUG
      NotificationHubMock.onPublishMockHandler?(name: name, sender: sender, userInfo: userInfo)
    #endif
    
    
    var didPublish = false
    if let notifications = self.internalNotifications[name] as? NSMutableArray {
      if sender != nil {
        for notification in notifications {
          let not:Notification = notification as! Notification<T>
          if not.sender == nil {
            not.sender = sender
            didPublish = not.publishUserInfo(userInfo)
            not.sender = nil
          }
          else if  not.sender === sender { didPublish = not.publishUserInfo(userInfo) }
        }
      }
      else {
        for notification in notifications {
          let not:Notification = notification as! Notification<T>
          if not.sender == nil { didPublish = not.publishUserInfo(userInfo) }
        }
      }
    }
    
    
    return didPublish
  }
  
  
  func publishNotification(notification: Notification<T>, userInfo:T? = nil) -> Bool {
    #if DEBUG
      NotificationHubMock.onPublishMockHandler?(name: notification.name, sender: notification.sender, userInfo: userInfo)
    #endif
    
    
    if (notification.hub === self) { return notification.publishUserInfo(userInfo) }
    else { return false }
  }
  
  func removeNotification(notification: Notification<T>) -> Bool {
    #if DEBUG
      NotificationHubMock.onRemoveMockHandler?(name:notification.name, sender:notification.sender)
    #endif
    
    if notification.hub !== self { return false }
    
    let name = notification.name
    var notifications = self.internalNotifications[name] as? NSMutableArray
    
    notifications?.removeObject(notification)
    
    
    if notifications?.count == 0  { self.internalNotifications.removeObjectForKey(name) }
    notification.hub = nil
    
    return true
  }
  
  func removeNotificationsName(name:String, sender: AnyObject? = nil) -> Bool {
    
    #if DEBUG
      NotificationHubMock.onRemoveMockHandler?(name:name, sender:sender)
    #endif
    
    var notifications = self.internalNotifications[name] as? NSMutableArray
    let preCount = notifications?.count
    
    if let notifications = notifications {
      for notification in notifications {
        let not:Notification = notification as! Notification<T>
        if not.sender == nil || not.sender === sender {
          notifications.removeObject(not)
          not.hub = nil
        }
      }
    }
    
    let postCount = notifications?.count
    if postCount == 0 {self.internalNotifications.removeObjectForKey(name) }
    
    
    return preCount != postCount
    
  }
  
  func removeAllNotificationsName(name:String) -> Bool {
    #if DEBUG
      NotificationHubMock.onRemoveMockHandler?(name:name, sender:nil)
    #endif
    
    let preCount = self.internalNotifications.count
    let notifications: NSArray? = self.internalNotifications[name] as? NSMutableArray
    self.internalNotifications.removeObjectForKey(name)
    
    if let notifications = notifications {
      for notification in notifications {
        (notification as! Notification<T>).hub = nil
      }
    }
    
    let postCount = self.internalNotifications.count
    return preCount != postCount
  }
  
  func removeAllNotificationsSender(sender:AnyObject) -> Bool {
    #if DEBUG
      NotificationHubMock.onRemoveMockHandler?(name:nil, sender:sender)
    #endif
    
    var count = self.internalNotifications.count
    let notifications = self.internalNotifications.allValues as? [[Notification<T>]]
    
    if let notifications = notifications {
      for notificationList in notifications {
        for notification in notificationList {
          if notification.sender === sender { notification.remove() }
        }
      }
    }
    self.internalNotifications.removeAllObjects()
    return count > 0
  }
  
  
  
  func removeAllNotifications() -> Bool {
    #if DEBUG
      NotificationHubMock.onRemoveMockHandler?(name:nil, sender:nil)
    #endif
    
    var count = self.internalNotifications.count
    let notifications = self.internalNotifications.allValues as? [[Notification<T>]]
    
    self.internalNotifications.removeAllObjects()
    if let notifications = notifications {
      for notificationList in notifications {
        for notification in notificationList { notification.hub = nil }
      }
    }
    self.internalNotifications.removeAllObjects()
    return count > 0
  }
}


extension Notification : Equatable {}
public func ==<T>(lhs: Notification<T>, rhs: Notification<T>) -> Bool { return lhs === rhs }

extension NotificationHub : Equatable {}
public func ==<T>(lhs: NotificationHub<T>, rhs: NotificationHub<T>) -> Bool { return lhs === rhs }


#if DEBUG
  public struct NotificationHubMock {
  
  private static var onPublishMockHandler:((name:String, sender:AnyObject?, userInfo:Any?) -> (Void))?
  static func onPublishingMockHandler(handler:(name:String, sender:AnyObject?, userInfo:Any?) -> (Void))  {
  self.onPublishMockHandler = handler
  }
  
  private static var onSubscribeMockHandler:((name:String, sender:AnyObject?) -> Void)?
  static func onSubscribingMock(handler:(name:String, sender:AnyObject?) -> Void)  {
  self.onSubscribeMockHandler = handler
  }
  
  private static var onRemoveMockHandler:((name:String?, sender:AnyObject?) -> Void)?
  static func onRemovingMockHandler(handler:(name:String?, sender:AnyObject?) -> Void)  {
  self.onRemoveMockHandler = handler
  }
  
  
  
  
  }
#endif
