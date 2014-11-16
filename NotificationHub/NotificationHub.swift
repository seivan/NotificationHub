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
  
  private convenience init(hub:NotificationHub<T>, name:String, sender:AnyObject?, handler:NotificationClosure) {
    self.init(name:name, sender:sender, handler:handler)
    self.hub = hub
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
  final private(set) var notifications    = NSMutableDictionary()
  
  final private(set) var allNotifications    = [Notification<T>]()
  final private var notificationsKeyedName   = [String:[Notification<T>]]()
  final private var notificationsKeyedSender = NSMapTable(
    keyOptions: NSPointerFunctionsOpaquePersonality|NSPointerFunctionsWeakMemory,
    valueOptions: NSPointerFunctionsStrongMemory)

  private class var defaultHub:NotificationHub<[String:Any]> {
    dispatch_once(&Static.hubToken) {
      Static.hub = NotificationHub<[String:Any]>()
    }
    return Static.hub!
  }
  
  init() {}

  
  func subscribeNotificationForName(name: String, sender: AnyObject? = nil, handler: (Notification<T>) -> Void) -> Notification<T> {
    let notification = Notification(hub:self, name: name, sender: sender, handler: handler)
    return self.subscribeNotification(notification)
  }

  func subscribeNotification(notification:Notification<T>) -> Notification<T> {
    if notification.hub != nil && notification.hub !== self { notification.hub?.removeNotification(notification) }
    notification.hub = self

    let name = notification.name
    if let notifications: NSMutableArray = self.notifications[notification.name] as NSMutableArray? {
      notifications.addObject(notification)
    }
    else {
      self.notifications[name] = NSMutableArray(object: notification)
    }

    return notification
  }
  

  func publishNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) -> Bool {
    
    var didPublish = false
    var notifications = self.notifications[name] as? NSMutableArray
    if let notifications = notifications {
      if sender != nil {
        for notification in notifications {
          let not:Notification = notification as Notification<T>
          if  notification.sender === sender { didPublish = not.publishUserInfo(userInfo) }
          else if notification.sender == nil {
            not.sender = sender
            didPublish = not.publishUserInfo(userInfo)
            not.sender = nil
          }
        }
      }
      else {
        for notification in notifications {
          let not:Notification = notification as Notification<T>
          if not.sender == nil {
            didPublish = not.publishUserInfo(userInfo)
          }
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
    
    var notifications = self.notifications[name] as? NSMutableArray
//    let count = notifications?.count
    notifications?.removeObject(notification)
    
    
//    return notifications?.count != count
    return true
  }
  
  func removeNotificationsName(name:String, sender: AnyObject? = nil) -> Bool {

    var notifications = self.notifications[name] as? NSMutableArray
    let preCount = notifications?.count
    
    if let notifications = notifications {
      if let sender: AnyObject = sender {
        for notification in notifications {
          let not:Notification = notification as Notification<T>
          if not.sender === sender {
            notifications.removeObject(not)
          }
        }
      }
      else {
        for notification in notifications {
          let not:Notification = notification as Notification<T>
          if not.sender == nil { notifications.removeObject(not) }
        }
        
      }

    }
    
    let postCount = notifications?.count
    if postCount == 0 {self.notifications.removeObjectForKey(name) }
    

    return preCount != postCount
    
  }
  
  func removeAllNotificationsName(name:String) -> Bool {
    let preCount = self.notifications.count
    self.notifications.removeObjectForKey(name)
    let postCount = self.notifications.count
    return preCount != postCount
  }

  
  
  func removeAllNotifications() -> Bool {
    var count = self.notifications.count
    self.notifications.removeAllObjects()
    return count != 0
  }



  
  

  
  
//  func subscribeNotificationForName(name: String, sender: AnyObject? = nil, handler: (Notification<T>) -> Void) -> Notification<T> {
//    let notification = Notification(hub:self, name: name, sender: sender, handler: handler)
//    return self.subscribeNotification(notification)
//  }
//  
//  func subscribeNotification(notification:Notification<T>) -> Notification<T> {
//    if notification.hub != nil && notification.hub !== self { notification.hub?.removeNotification(notification) }
//    notification.hub = self
//    
//    let name = notification.name
//    
//    if let sender: AnyObject = notification.sender {
//      if var keyedNotifications = self._observersKeyedNameForSender(sender) {
//        var notifications = keyedNotifications[name] ?? [Notification<T>]()
//        notifications.append(notification)
//        keyedNotifications[name] = notifications
//        self.notificationsKeyedSender.setObject(keyedNotifications, forKey: sender)
//        
//      }
//      else { self.notificationsKeyedSender.setObject([name:[notification]], forKey: sender) }
//    }
//    else {
//      if var notifications = self.notificationsKeyedName[name] {
//        notifications.append(notification)
//        self.notificationsKeyedName[name] = notifications
//      }
//      else {
//        self.notificationsKeyedName[name] = [notification]
//      }
//    }
//    
//    
//    self.allNotifications.append(notification)
//    return notification
//  }
//
//  func publishNotification(notification: Notification<T>, userInfo:T? = nil) -> Bool {
//    if notification.hub === self && contains(self.allNotifications, notification) { return notification.publishUserInfo(userInfo) }
//    else { return false }
//  }
//  
//  func publishNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) -> Bool {
//    var notifications = [Notification<T>]()
//    
//    
//    if let sender: AnyObject = sender {
//      if let notificationsWithSender = self._observersKeyedNameForSender(sender)?[name] {
//        notifications.extend(notificationsWithSender)
//      }
//    }
//    
//    var notificationsKeyed = self.notificationsKeyedName[name]
//    if let notificationsKeyed = notificationsKeyed  {
//      notifications.extend(notificationsKeyed)
//      for not in notificationsKeyed { not.sender = sender}
//    }
//
//
//    for notification in notifications { notification.publishUserInfo(userInfo) }
//    if let notificationsKeyed = notificationsKeyed  {
//      notifications.extend(notificationsKeyed)
//      for not in notificationsKeyed { not.sender = nil}
//    }
//
//    return notifications.isEmpty == false
//    
//  }
//  
//  func removeNotification(notification: Notification<T>) -> Bool {
//    let sender: AnyObject? = notification.sender
//    let name = notification.name
//    
//    
//    if let sender: AnyObject = sender {
//      var keyedNotifications = self._observersKeyedNameForSender(sender)
//      if let notifications = keyedNotifications?[name] {
//        let newNotifications = notifications.filter { ($0 as Notification<T>) !== notification }
//        keyedNotifications![name] = newNotifications
//        if newNotifications.isEmpty { keyedNotifications![name] = nil }
//        self.notificationsKeyedSender.setObject(keyedNotifications!, forKey: sender)
//      }
//
//    }
//    else {
//      if let notifications = self.notificationsKeyedName[name] {
//        let newNotifications = notifications.filter { ($0 as Notification<T>) !== notification }
//        if newNotifications.isEmpty { self.notificationsKeyedName[name] = nil }
//        else { self.notificationsKeyedName[name] = newNotifications }
//      }
//    }
//    let filteredNotifications = self.allNotifications.filter  { return $0 != notification }
//    let hasRemoved = self.allNotifications.count != filteredNotifications.count
//    self.allNotifications = filteredNotifications;
//    return hasRemoved;
//    
//  }
//  
//  func removeNotificationsName(name:String, sender: AnyObject? = nil) -> Bool {
//    let sender: AnyObject? = sender
//
//    if let sender: AnyObject = sender {
//      var keyedNotifications = self._observersKeyedNameForSender(sender)
//      if let notifications = keyedNotifications?[name] {
//        let newNotifications = notifications.filter { ($0 as Notification<T>).name != name }
//        keyedNotifications![name] = newNotifications
//        if newNotifications.isEmpty { keyedNotifications![name] = nil }
//        self.notificationsKeyedSender.setObject(keyedNotifications!, forKey: sender)
//      }
//      else { self._removeNotificationWithName(name) }
//    }
//    else {
//      self._removeNotificationWithName(name)
//    }
//    
//    let filteredNotifications = self.allNotifications.filter  {
//      if sender != nil { return ($0.sender !== sender && $0.name != name) }
//      else { return ($0.sender !== sender || $0.name != name)}
//    }
//    let hasRemoved = self.allNotifications.count != filteredNotifications.count
//
//    self.allNotifications = filteredNotifications;
//    return hasRemoved;
//
//
//  }
//  
//  func removeAllNotificationsName(name:String) -> Bool {
//    let originalCount = self.allNotifications.count
//    
//    var observersKeyedName =  self.notificationsKeyedSender.objectEnumerator().allObjects as [[String:[Notification<T>]]]
//    observersKeyedName.append(self.notificationsKeyedName)
//    for key in observersKeyedName {
//      let notifications = key[name]
//      if let notifications = notifications { for notification in notifications { notification.remove() } }
//    }
//    
//
//    let hasRemoved = self.allNotifications.count != originalCount
//
//    return hasRemoved;
//
//  }
//  
//  func removeAllNotifications() -> Bool {
//    var count = self.allNotifications.count
//    self.notificationsKeyedName.removeAll(keepCapacity: false)
//    self.allNotifications.removeAll(keepCapacity: false)
//    self.notificationsKeyedSender.removeAllObjects()
//    return count != 0
//  }
//  
//  
//  private  func _removeNotificationWithName(name:String) {
//    if let notifications = self.notificationsKeyedName[name] {
//      let newNotifications = notifications.filter { ($0 as Notification<T>).name != name }
//      if newNotifications.isEmpty { self.notificationsKeyedName[name] = nil }
//      else { self.notificationsKeyedName[name] = newNotifications }
//    }
//  }
//  
//
//  final func _observersKeyedNameForSender(sender:AnyObject) -> [String:[Notification<T>]]? {
//    return self.notificationsKeyedSender.objectForKey(sender) as [String:[Notification<T>]]?
//  }

  

}


