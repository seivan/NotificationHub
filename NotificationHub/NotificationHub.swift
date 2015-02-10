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

  final var notifications = [String: Array<Notification<T>>]()
  
  private class var defaultHub:NotificationHub<[String:Any]> {
    dispatch_once(&Static.hubToken) {
      Static.hub = NotificationHub<[String:Any]>()
    }
    return Static.hub!
  }
  
  init() { }
  
  
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
    var notifications = self.notifications[name]
    if notifications != nil  {
      notifications?.append(notification)
    }
    else {
      notifications = [notification]

    }
    
    self.notifications[name] = notifications
    
    return notification
  }
  
  
  func publishNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) -> Bool {
    #if DEBUG
      NotificationHubMock.onPublishMockHandler?(name: name, sender: sender, userInfo: userInfo)
    #endif
    
    
    var didPublish = false
    var notifications = self.notifications[name]
    if let notifications = notifications {
      if sender != nil {
        for not in notifications {
          if not.sender == nil {
            not.sender = sender
            didPublish = not.publishUserInfo(userInfo)
            not.sender = nil
          }
          else if  not.sender === sender { didPublish = not.publishUserInfo(userInfo) }
        }
      }
      else {
        for not in notifications {
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
    var notifications = self.notifications[name]

    if var notifications = notifications, let index = find(notifications, notification) {
          notifications.removeAtIndex(index)
    }



    
    if notifications?.count == 0  { self.notifications.removeValueForKey(name) }
    else                          { self.notifications[name] = notifications!  }
    notification.hub = nil
    
    return true
  }
  
  func removeNotificationsName(name:String, sender: AnyObject? = nil) -> Bool {
    
    #if DEBUG
      NotificationHubMock.onRemoveMockHandler?(name:name, sender:sender)
    #endif
    
    var notifications = self.notifications[name]
    let preCount = notifications?.count
    
    if var notifications = notifications {
      for not in notifications {
        if not.sender == nil || not.sender === sender {
          if let index = find(notifications, not) {
          notifications.removeAtIndex(index)
          not.hub = nil
          }
        }
      }
    }
    
    let postCount = notifications?.count
    if postCount == 0 { self.notifications.removeValueForKey(name) }
    else              { self.notifications[name] = notifications!  }
    
    
    return preCount != postCount
    
  }
  
  func removeAllNotificationsName(name:String) -> Bool {
    #if DEBUG
      NotificationHubMock.onRemoveMockHandler?(name:name, sender:nil)
    #endif
    
    let preCount = self.notifications.count
    let notifications = self.notifications[name]
    self.notifications.removeValueForKey(name)
    
    if let notifications = notifications {
      for not in notifications {
        not.hub = nil
      }
    }
    
    let postCount = self.notifications.count
    return preCount != postCount
  }
  
  func removeAllNotificationsSender(sender:AnyObject) -> Bool {
    #if DEBUG
      NotificationHubMock.onRemoveMockHandler?(name:nil, sender:sender)
    #endif
    
    var count = self.notifications.count
    let notifications = self.notifications.values.array
    

      for notificationList in notifications {
        for notification in notificationList {
          if notification.sender === sender { notification.remove() }
        }
      }

    self.notifications.removeAll(keepCapacity: false)
    return count > 0
  }
  
  
  
  func removeAllNotifications() -> Bool {
    #if DEBUG
      NotificationHubMock.onRemoveMockHandler?(name:nil, sender:nil)
    #endif
    
    var count = self.notifications.count
    let notifications = self.notifications.values
    
    self.notifications.removeAll(keepCapacity: false)

      for notificationList in notifications {
        for notification in notificationList { notification.hub = nil }
      }

    return count > 0
  }
}


extension Notification : Hashable {
  public var hashValue: Int {
    return ObjectIdentifier(self).hashValue
  }

}
public func ==<T>(lhs: Notification<T>, rhs: Notification<T>) -> Bool { return lhs === rhs }

extension NotificationHub : Hashable {
  public var hashValue: Int {
    return ObjectIdentifier(self).hashValue
  }

}
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
