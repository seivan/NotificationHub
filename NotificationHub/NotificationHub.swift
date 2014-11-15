import Foundation

class Notification<T> : Equatable {
  typealias NotificationClosure = (Notification<T>) -> Void
  let name:String
  private(set) weak var sender:AnyObject?
  private(set) var userInfo:T?
  private let closure:NotificationClosure

  
  private weak var hub:NotificationHub<T>?
  private weak var hubX:NotificationCenter?

  
  init(name:String, sender:AnyObject?, handler:NotificationClosure) {
    self.name     = name
    self.closure  = handler
    self.sender   = sender

  }
  
  private convenience init(hub:NotificationHub<T>, name:String, sender:AnyObject?, handler:NotificationClosure) {
    self.init(name:name, sender:sender, handler:handler)
    self.hub = hub
  }

  private convenience init(hub:NotificationCenter, name:String, sender:AnyObject?, handler:NotificationClosure) {
    self.init(name:name, sender:sender, handler:handler)
    self.hubX = hub
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
  static var instanceToken : dispatch_once_t = 0
  static var hubToken : dispatch_once_t = 0
  static var instance : NotificationHub<[String:Any]>? = nil
  static var hub : NotificationCenter? = nil

}


var NotificationHubDefault : NotificationHub<[String:Any]> {
get { return NotificationHub<[String:Any]>.defaultHub }
}


class NotificationCenter {
  final private(set) var notifications    = [AnyObject]()

  class var defaultHub:NotificationCenter{
    dispatch_once(&Static.hubToken) {
      Static.hub = NotificationCenter()
    }
    return Static.hub!
  }

  init() {}
  func subscribeNotificationForName<T>(name: String, sender: AnyObject? = nil, type:T, handler: (Notification<T>) -> Void) -> Notification<T> {
    let notification = Notification(hub:self, name: name, sender: sender, handler: handler)
    return self.subscribeNotification(notification)
  }
  
  func subscribeNotification<T>(notification:Notification<T>) -> Notification<T> {
    if notification.hub != nil && notification.hub !== self { notification.hubX?.removeNotification(notification) }
    notification.hubX = self
    self.notifications.append(notification)
    return notification
  }
  
  func removeNotification<T>(notification: Notification<T>) -> Bool {
    var notifications = self.notifications as [Notification<T>]
    if let index = find(notifications, notification) {
      self.notifications.removeAtIndex(index)
      return true
    }
    else { return false }
    
  }
  
  func publishNotificationName<T>(name: String, sender: AnyObject? = nil, userInfo:T? = nil) -> Bool {
    var notifications = self.notifications
    
    var didPublish = false
    for notification in self.notifications {
      if notification is Notification<T> {
      if name == notification.name && sender === notification.sender {
        (notification as Notification<T>).publishUserInfo(userInfo)
        didPublish = true
        }
      }
    }
    return didPublish
    
    
  }




}

class NotificationHub<T>  {
  
  final private(set) var allNotifications    = [Notification<T>]()
  final private var notificationsKeyedName   = [String:[Notification<T>]]()
  final private var notificationsKeyedSender = NSMapTable(
    keyOptions: NSPointerFunctionsOpaquePersonality|NSPointerFunctionsWeakMemory,
    valueOptions: NSPointerFunctionsStrongMemory)

  private class var defaultHub:NotificationHub<[String:Any]> {
    dispatch_once(&Static.instanceToken) {
      Static.instance = NotificationHub<[String:Any]>()
    }
    return Static.instance!
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
    
    if let sender: AnyObject = notification.sender {
      if var keyedNotifications = self._observersKeyedNameForSender(sender) {
        var notifications = keyedNotifications[name] ?? [Notification<T>]()
        notifications.append(notification)
        keyedNotifications[name] = notifications
        self.notificationsKeyedSender.setObject(keyedNotifications, forKey: sender)
        
      }
      else { self.notificationsKeyedSender.setObject([name:[notification]], forKey: sender) }
    }
    else {
      if var notifications = self.notificationsKeyedName[name] {
        notifications.append(notification)
        self.notificationsKeyedName[name] = notifications
      }
      else {
        self.notificationsKeyedName[name] = [notification]
      }
    }
    
    
    self.allNotifications.append(notification)
    return notification
  }

  func publishNotification(notification: Notification<T>, userInfo:T? = nil) -> Bool {
    if notification.hub === self && contains(self.allNotifications, notification) { return notification.publishUserInfo(userInfo) }
    else { return false }
  }
  
  func publishNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) -> Bool {
    var notifications = [Notification<T>]()
    
    
    if let sender: AnyObject = sender {
      if let notificationsWithSender = self._observersKeyedNameForSender(sender)?[name] {
        notifications.extend(notificationsWithSender)
      }
    }
    
    var notificationsKeyed = self.notificationsKeyedName[name]
    if let notificationsKeyed = notificationsKeyed  {
      notifications.extend(notificationsKeyed)
      for not in notificationsKeyed { not.sender = sender}
    }


    for notification in notifications { notification.publishUserInfo(userInfo) }
    if let notificationsKeyed = notificationsKeyed  {
      notifications.extend(notificationsKeyed)
      for not in notificationsKeyed { not.sender = nil}
    }

    return notifications.isEmpty == false
    
  }
  
  func removeNotification(notification: Notification<T>) -> Bool {
    let sender: AnyObject? = notification.sender
    let name = notification.name
    
    
    if let sender: AnyObject = sender {
      var keyedNotifications = self._observersKeyedNameForSender(sender)
      if let notifications = keyedNotifications?[name] {
        let newNotifications = notifications.filter { ($0 as Notification<T>) !== notification }
        keyedNotifications![name] = newNotifications
        if newNotifications.isEmpty { keyedNotifications![name] = nil }
        self.notificationsKeyedSender.setObject(keyedNotifications!, forKey: sender)
      }

    }
    else {
      if let notifications = self.notificationsKeyedName[name] {
        let newNotifications = notifications.filter { ($0 as Notification<T>) !== notification }
        if newNotifications.isEmpty { self.notificationsKeyedName[name] = nil }
        else { self.notificationsKeyedName[name] = newNotifications }
      }
    }
    let filteredNotifications = self.allNotifications.filter  { return $0 != notification }
    let hasRemoved = self.allNotifications.count != filteredNotifications.count
    self.allNotifications = filteredNotifications;
    return hasRemoved;
    
  }
  
  func removeNotificationsName(name:String, sender: AnyObject? = nil) -> Bool {
    let sender: AnyObject? = sender

    if let sender: AnyObject = sender {
      var keyedNotifications = self._observersKeyedNameForSender(sender)
      if let notifications = keyedNotifications?[name] {
        let newNotifications = notifications.filter { ($0 as Notification<T>).name != name }
        keyedNotifications![name] = newNotifications
        if newNotifications.isEmpty { keyedNotifications![name] = nil }
        self.notificationsKeyedSender.setObject(keyedNotifications!, forKey: sender)
      }
      else { self._removeNotificationWithName(name) }
    }
    else {
      self._removeNotificationWithName(name)
    }
    
    let filteredNotifications = self.allNotifications.filter  {
      if sender != nil { return ($0.sender !== sender && $0.name != name) }
      else { return ($0.sender !== sender || $0.name != name)}
    }
    let hasRemoved = self.allNotifications.count != filteredNotifications.count

    self.allNotifications = filteredNotifications;
    return hasRemoved;


  }
  
  func removeAllNotificationsName(name:String) -> Bool {
    let originalCount = self.allNotifications.count
    
    var observersKeyedName =  self.notificationsKeyedSender.objectEnumerator().allObjects as [[String:[Notification<T>]]]
    observersKeyedName.append(self.notificationsKeyedName)
    for key in observersKeyedName {
      let notifications = key[name]
      if let notifications = notifications { for notification in notifications { notification.remove() } }
    }
    

    let hasRemoved = self.allNotifications.count != originalCount

    return hasRemoved;

  }
  
  func removeAllNotifications() -> Bool {
    var count = self.allNotifications.count
    self.notificationsKeyedName.removeAll(keepCapacity: false)
    self.allNotifications.removeAll(keepCapacity: false)
    self.notificationsKeyedSender.removeAllObjects()
    return count != 0
  }
  
  
  private  func _removeNotificationWithName(name:String) {
    if let notifications = self.notificationsKeyedName[name] {
      let newNotifications = notifications.filter { ($0 as Notification<T>).name != name }
      if newNotifications.isEmpty { self.notificationsKeyedName[name] = nil }
      else { self.notificationsKeyedName[name] = newNotifications }
    }
  }
  

  final func _observersKeyedNameForSender(sender:AnyObject) -> [String:[Notification<T>]]? {
    return self.notificationsKeyedSender.objectForKey(sender) as [String:[Notification<T>]]?
  }

  

}


