import Foundation
import SpriteKit

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
  
  final func fireUserInfo(userInfo:T?) -> Bool {
    self.userInfo = userInfo
    self.closure(self)
    self.userInfo = nil
    return true
  }
  
  final func remove() {
    self.userInfo = nil
    self.hub?.removeNotification(self)
    self.hub = nil
    self.sender = nil
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
  
  final private func observersKeyedNameForSender(sender:AnyObject) -> [String:[Notification<T>]]? {
    return self.notificationsKeyedSender.objectForKey(sender) as [String:[Notification<T>]]?
  }
  
  func subscribeNotificationForName(name: String, sender: AnyObject? = nil, block: (Notification<T>) -> Void) -> Notification<T> {
    let notification = Notification(hub:self, name: name, sender: sender, closure: block)
    
    if let sender: AnyObject = sender {
      if var notifications = self.observersKeyedNameForSender(sender)?[name] {notifications.append(notification) }
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
    if contains(self.allNotifications, notification) { return notification.fireUserInfo(nil) }
    else { return false }
  }
  
  func publishNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) {
    var notifications: [Notification<T>]?
    
    if let sender: AnyObject = sender { notifications = self.observersKeyedNameForSender(sender)?[name] }


    notifications = notifications ?? self.notificationsKeyedName[name]

    if let notifications = notifications { for notification in notifications { notification.fireUserInfo(userInfo) } }
    
  }
  
  func removeNotification(notification: Notification<T>) {
    let sender: AnyObject? = notification.sender
    let name = notification.name
    
    
    if let sender: AnyObject = sender {
      if let notifications = self.observersKeyedNameForSender(sender)?[name] {
        let newNotifications = notifications.filter { ($0 as Notification<T>) !== notification }
        if newNotifications.isEmpty { self.notificationsKeyedSender.removeObjectForKey(sender) }
        else { self.notificationsKeyedSender.setObject(newNotifications, forKey: sender) }
      }

    }
    else {
      if let notifications = self.notificationsKeyedName[name] {
        let newNotifications = notifications.filter { ($0 as Notification<T>) !== notification }
        if newNotifications.isEmpty { self.notificationsKeyedName[name] = nil }
        else { self.notificationsKeyedName[name] = newNotifications }
      }
    }
    

    self.allNotifications = self.allNotifications.filter  { return $0 != notification }
    
  }
  
  func removeNotificationsName(name:String, sender: AnyObject? = nil) {
    let name = name
    let sender: AnyObject? = sender
    
    if let sender: AnyObject = sender {
      if let notifications = self.observersKeyedNameForSender(sender)?[name] {
        let newNotifications = notifications.filter { ($0 as Notification<T>).name != name }
        if newNotifications.isEmpty { self.notificationsKeyedSender.removeObjectForKey(sender) }
        else { self.notificationsKeyedSender.setObject(newNotifications, forKey: sender) }
      }
      else { self.removeNotificationWithName(name) }
    }
    else { self.removeNotificationWithName(name) }
    
    self.allNotifications = self.allNotifications.filter  {
      return $0.name != name && $0.sender !== sender
    }

  }
  
  func removeAllNotificationsName(name:String) {
    var observersKeyedName = self.notificationsKeyedSender.objectEnumerator().allObjects as [[String:[Notification<T>]]]
    observersKeyedName.append(self.notificationsKeyedName)
    for key in observersKeyedName {
      let notifications = key[name]
      if let notifications = notifications { for notification in notifications { notification.remove() } }
    }
    
//    self.notificationsUnsorted = self.notificationsUnsorted.filter  {
//      return $0.name != name && $0.sender !== sender
//    }

    

  }
  
  func removeAllNotifications() {
    self.notificationsKeyedName.removeAll(keepCapacity: false)
    self.allNotifications.removeAll(keepCapacity: false)
    self.notificationsKeyedSender.removeAllObjects()
  }
  
  private  func removeNotificationWithName(name:String) {
    if let notifications = self.notificationsKeyedName[name] {
      let newNotifications = notifications.filter { ($0 as Notification<T>).name != name }
      if newNotifications.isEmpty { self.notificationsKeyedName[name] = nil }
      else { self.notificationsKeyedName[name] = newNotifications }
    }
  }
  

  

}


