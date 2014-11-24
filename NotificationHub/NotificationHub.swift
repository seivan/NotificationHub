import Foundation

class Notification<T> : Equatable {
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
    self.userInfo = nil
    self.hub?.removeNotification(self)
    self.hub = nil
    return true
  }
  
  
}

func ==<T>(lhs: Notification<T>, rhs: Notification<T>) -> Bool {
    return lhs === rhs
}



//private extension Array {
//  func _executeNotifications() {
//   for t in self { (t as Notification<T>).execute() }
//  }
//  mutating func _removeNotification <U>(notification:Notification<U>) {
//    self = self.filter { ($0 as Notification<U>) !== notification }
//  }
//  mutating func _removeNotification(name:String) {
//    self = self.filter { ($0 as Notification<Any>).name != name }
//  }
//}

private struct Static {
  static var hubToken : dispatch_once_t = 0
  static var hub : NotificationHub<[String:Any]>? = nil
}


var NotificationHubDefault : NotificationHub<[String:Any]> {
get { return NotificationHub<[String:Any]>.defaultHub }
}



class NotificationHub<T>  {
  final private var internalNotifications    =  NSMutableDictionary(capacity: 1000)
  final var notifications:[String: [Notification<T>]] {
    return self.internalNotifications as AnyObject as [String: [Notification<T>]]
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
    if notification.hub !== nil { notification.hub?.removeNotification(notification) }
    notification.hub = self

    let name = notification.name
    if let notifications: NSMutableArray = self.internalNotifications[notification.name] as NSMutableArray? {
      notifications.addObject(notification)
    }
    else {
      var array = NSMutableArray(capacity: 10)
      array.addObject(notification)
      self.internalNotifications[name] = NSMutableArray(object: notification)
    }

    return notification
  }
  

  func publishNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) -> Bool {
    
    var didPublish = false
    var notifications = self.internalNotifications[name] as? NSMutableArray
    if let notifications = notifications {
      if sender != nil {
        for notification in notifications {
          let not:Notification = notification as Notification<T>
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
          let not:Notification = notification as Notification<T>
          if not.sender == nil { didPublish = not.publishUserInfo(userInfo) }
        }
      }
    }
    
    
    return didPublish
  }

  
  func publishNotification(notification: Notification<T>, userInfo:T? = nil) -> Bool {
    if (notification.hub === self) { return notification.publishUserInfo(userInfo) }
    else { return false }
  }
  
  func removeNotification(notification: Notification<T>) -> Bool {
    if notification.hub !== self { return false }

    let name = notification.name
    var notifications = self.internalNotifications[name] as? NSMutableArray

    notifications?.removeObject(notification)
    
    
    if notifications?.count == 0  { self.internalNotifications.removeObjectForKey(name) }
    notification.hub = nil

    return true
  }
  
  func removeNotificationsName(name:String, sender: AnyObject? = nil) -> Bool {

    var notifications = self.internalNotifications[name] as? NSMutableArray
    let preCount = notifications?.count
    
    if let notifications = notifications {
      for notification in notifications {
        let not:Notification = notification as Notification<T>
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
    let preCount = self.internalNotifications.count
    self.internalNotifications.removeObjectForKey(name)
    let postCount = self.internalNotifications.count
    return preCount != postCount
  }

  func removeAllNotificationsSender(sender:AnyObject) -> Bool {
    let preCount = self.internalNotifications.count
    self.internalNotifications.toManyRelationshipKeys
    let postCount = self.internalNotifications.count
    return preCount != postCount
  }

  
  
  func removeAllNotifications() -> Bool {
    var count = self.internalNotifications.count
    self.internalNotifications.removeAllObjects()
    return count > 0
  }
}


