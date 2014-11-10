import Foundation

class Notification<T> : Equatable {
  typealias NotificationClosure = (Notification<T>) -> Void
  let name:String
  private(set) weak var sender:AnyObject?
  private(set) var userInfo:T?
  private let closure:NotificationClosure
  
  private weak var hub:NotificationHub<T>?

  private init(hub:NotificationHub<T>, name:String, sender:AnyObject?, closure:NotificationClosure) {
    self.hub      = hub
    self.name     = name
    self.closure  = closure
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
    self.sender = nil
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
  static var onceToken : dispatch_once_t = 0
  static var instance : NotificationHub<[String:Any]>? = nil
}


var NotificationHubDefault : NotificationHub<[String:Any]> {
get { return NotificationHub<[String:Any]>.defaultHub }
}


class NotificationHub<T> {
  
  final private(set) var allNotifications    = [Notification<T>]()
  final private var notificationsKeyedName   = [String:[Notification<T>]]()
  final private var notificationsKeyedSender = NSMapTable(
    keyOptions: NSPointerFunctionsOpaquePersonality|NSPointerFunctionsWeakMemory,
    valueOptions: NSPointerFunctionsStrongMemory)

  private class var defaultHub:NotificationHub<[String:Any]> {
    dispatch_once(&Static.onceToken) {
      Static.instance = NotificationHub<[String:Any]>()
    }
    return Static.instance!
  }
  
  init() {}
  
  
  func subscribeNotificationForName(name: String, sender: AnyObject? = nil, block: (Notification<T>) -> Void) -> Notification<T> {
    let notification = Notification(hub:self, name: name, sender: sender, closure: block)
    
    if let sender: AnyObject = sender {
      if var notifications = self._observersKeyedNameForSender(sender)?[name] {notifications.append(notification) }
      else { self.notificationsKeyedSender.setObject([name:[notification]], forKey: sender) }
    }
    else {
      if var notifications = self.notificationsKeyedName[name] { notifications.append(notification) }
      else { self.notificationsKeyedName[name] = [notification] }
    }

    self.allNotifications.append(notification)
    return notification
  }
  

  func publishNotification(notification: Notification<T>) -> Bool {
    if contains(self.allNotifications, notification) { return notification.publishUserInfo(nil) }
    else { return false }
  }
  
  func publishNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) -> Bool {
    var notifications: [Notification<T>]?
    
    if let sender: AnyObject = sender { notifications = self._observersKeyedNameForSender(sender)?[name] }

    notifications = notifications ?? self.notificationsKeyedName[name]

    if let notifications = notifications { for notification in notifications { notification.publishUserInfo(userInfo) } }
    return notifications?.isEmpty == false
    
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
    let name = name
    let sender: AnyObject? = sender
    
    if let sender: AnyObject = sender {
      if let notifications = self._observersKeyedNameForSender(sender)?[name] {
        let newNotifications = notifications.filter { ($0 as Notification<T>).name != name }
        if newNotifications.isEmpty { self.notificationsKeyedSender.removeObjectForKey(sender) }
        else { self.notificationsKeyedSender.setObject(newNotifications, forKey: sender) }
      }
      else { self._removeNotificationWithName(name) }
    }
    else { self._removeNotificationWithName(name) }
    
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
  

  final private func _observersKeyedNameForSender(sender:AnyObject) -> [String:[Notification<T>]]? {
    return self.notificationsKeyedSender.objectForKey(sender) as [String:[Notification<T>]]?
  }

  

}


