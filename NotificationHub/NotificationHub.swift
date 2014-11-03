import Foundation
import SpriteKit

class Notification<T> : Equatable {
  typealias NotificationClosure = (Notification<T>) -> Void
  let name:String
  private(set) weak var sender:AnyObject?
  private let closure:NotificationClosure
  private(set) var userInfo:T?
  private weak var hub:NotificationHub<T>?

  private init(hub:NotificationHub<T>, name:String, sender:AnyObject?, closure:NotificationClosure) {
    self.name = name
    self.closure = closure
    self.sender = sender
  }
  final private func execute() -> Bool {
    self.closure(self)
    return true
  }
  
  final func remove() {
    self.hub?.removeNotification(self)
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
  
  final private var notificationsUnsorted    = [Notification<T>]()
  final private var notificationsKeyedName   = [String:[Notification<T>]]()
  final private let notificationsKeyedSender = NSMapTable(
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
  
  func addObserverForName(name: String, sender: AnyObject? = nil, block: (Notification<T>) -> Void) -> Notification<T> {
    let notification = Notification(hub:self, name: name, sender: sender, closure: block)
    
    if let sender: AnyObject = sender {
      if var notifications = self.observersKeyedNameForSender(sender)?[name] {notifications.append(notification) }
      else { self.notificationsKeyedSender.setObject([name:[notification]], forKey: sender) }
    }
    else {
      if var notifications = self.notificationsKeyedName[name] { notifications.append(notification) }
      else { self.notificationsKeyedName[name] = [notification] }
    }

    self.notificationsUnsorted.append(notification)
    return notification
  }
  

  func postNotification(notification: Notification<T>) -> Bool {
    if contains(self.notificationsUnsorted, notification) { return notification.execute() }
    else { return false }
    
    //if let n = (self.notificationsUnsorted.filter { $0 === notification }).first { return n.execute() }
    //else { return false }
  }
  
  func postNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) {
    var notifications: [Notification<T>]?
    
    if let sender: AnyObject = sender {
      notifications = self.observersKeyedNameForSender(sender)?[name]
    }
//    else  {
//      notifications = self.notificationsKeyedName[name]
//    }

    notifications = notifications ?? self.notificationsKeyedName[name]
//    ADD USERINFO IN EXECUTE and then remove after posting
    if let notifications = notifications {
      for notification in notifications { notification.execute() }
    }
    
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
    
//    self.observersUnsorted._removeNotification(notification)
    
   }
  }
  
  //Remove notification with name or name & sender
  func removeNotification(name:String, sender: AnyObject? = nil) {
    let name = name
    let sender: AnyObject? = sender

    
    if let sender: AnyObject = sender {
      if let notifications = self.observersKeyedNameForSender(sender)?[name] {
        let newNotifications = notifications.filter { ($0 as Notification<T>).name != name }
        if newNotifications.isEmpty { self.notificationsKeyedSender.removeObjectForKey(sender) }
        else { self.notificationsKeyedSender.setObject(newNotifications, forKey: sender) }
      }
      
    }
    else {
//      self.notificationsKeyedName[name]?._removeNotification(name)
      if let notifications = self.notificationsKeyedName[name] {
        let newNotifications = notifications.filter { ($0 as Notification<T>).name != name }
        if newNotifications.isEmpty { self.notificationsKeyedName[name] = nil }
        else { self.notificationsKeyedName[name] = newNotifications }

    }
    
//    self.notificationsUnsorted._removeNotification(name)
    
   }
  }
  
  //Remove notifications with the name from both sender and without sender
  func removeAllNotifications(name:String) {
    var observersKeyedName = self.notificationsKeyedSender.objectEnumerator().allObjects as [[String:[Notification<T>]]]
    var keys = self.notificationsKeyedSender.keyEnumerator().allObjects as [AnyObject]
    
    var notificationsToRemove:[Notification<T>]?
    
    for key in keys {
      var pairs = self.observersKeyedNameForSender(key)
      if var pairs = pairs {
        notificationsToRemove = pairs.removeValueForKey(name)
        if pairs.isEmpty { self.notificationsKeyedSender.removeObjectForKey(key) }
      }
    }
    
    if let moreNotificationsToRemove = self.notificationsKeyedName.removeValueForKey(name) {

      if let notificationsToRemove = notificationsToRemove {
        notificationsToRemove + moreNotificationsToRemove
      }
   
    }
    
    
    
//      pairs.removeValueForKey(name)
//      if(pairs?.isEmpty) { self.observersKeyedSender.removeObjectForKey(key) }
//      else {
//        self.observersKeyedSender.setObject(pairs, forKey: key)
//      }
//    }

  }
  
//  func removeAllNotifications(sender:AnyObject) {
//    
//  }
//

  

}


