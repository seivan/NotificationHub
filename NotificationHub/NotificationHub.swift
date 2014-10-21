import Foundation
import SpriteKit

class Notification<T> {
  typealias NotificationClosure = (Notification<T>) -> Void
  let name:String
  private(set) weak var sender:AnyObject?
  private let closure:NotificationClosure
  private(set) var userInfo:T?

  private init(name:String, sender:AnyObject?, closure:NotificationClosure) {
    self.name = name
    self.closure = closure
    self.sender = sender
  }
  final private func execute() -> Bool {
    self.closure(self)
    return true
  }
  
}


private extension Array {
  func _executeNotifications() {
    for t in self { (t as Notification<Any>).execute() }
  }
  mutating func _removeNotification <U>(notification:Notification<U>) {
    self = self.filter { ($0 as Notification<U>) !== notification }
  }
  mutating func _removeNotification(name:String) {
    self = self.filter { ($0 as Notification<Any>).name != name }
  }


}

private struct Static {
  static var onceToken : dispatch_once_t = 0
  static var instance : NotificationHub<[String:Any]>? = nil
}


var NotificationHubDefault : NotificationHub<[String:Any]> {
get { return NotificationHub<[String:Any]>.defaultHub }
}


class NotificationHub<T> {
  
  final private var observersUnsorted    = [Notification<T>]()
  final private var observersKeyedName   = [String:[Notification<T>]]()
  final private let observersKeyedSender = NSMapTable(
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
    return self.observersKeyedSender.objectForKey(sender) as [String:[Notification<T>]]?
  }
  
  func addObserverForName(name: String, sender: AnyObject? = nil, block: (Notification<T>) -> Void) -> Notification<T> {
    let notification = Notification(name: name, sender: sender, closure: block)
    
    if let sender: AnyObject = sender {
      if var observers = self.observersKeyedNameForSender(sender)?[name] { observers.append(notification) }
      else { self.observersKeyedSender.setObject([name:[notification]], forKey: sender) }
      
    }
    else {
      if var observers = self.observersKeyedName[name] { observers.append(notification) }
      else { self.observersKeyedName[name] = [notification] }
    }

    self.observersUnsorted.append(notification)
    return notification
  }
  

  func postNotification(notification: Notification<T>) -> Bool {
    if let n = (self.observersUnsorted.filter { $0 === notification }).first { return n.execute() }
    else { return false }
  }
  
  func postNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) {
    if let sender: AnyObject = sender {
      let observersKeyedName = self.observersKeyedSender.objectForKey(sender) as? [String:[Notification<T>]]
      observersKeyedName?[name]?._executeNotifications()
      
    }
    else { self.observersKeyedName[name]?._executeNotifications() }
  }
  
  func removeNotification(notification: Notification<T>) {
    let sender: AnyObject? = notification.sender
    let name = notification.name
    
    if let sender: AnyObject = sender {
      if var observers = self.observersKeyedNameForSender(sender)?[name] {
        observers._removeNotification(notification)
        if observers.isEmpty { self.observersKeyedSender.removeObjectForKey(sender) }
        else { self.observersKeyedSender.setObject(observers, forKey: sender) }
      }

    }
    else {
      self.observersKeyedName[name]?._removeNotification(notification)

    }
    
    self.observersUnsorted._removeNotification(notification)
    
  }
  
  //Remove notification with name or name & sender
  func removeNotification(name:String, sender: AnyObject? = nil) {
    let sender: AnyObject? = sender
    let name = name
    
    if let sender: AnyObject = sender {
      if var observers = self.observersKeyedNameForSender(sender)?[name] {
        observers._removeNotification(name)
        if observers.isEmpty { self.observersKeyedSender.removeObjectForKey(sender) }
        else { self.observersKeyedSender.setObject(observers, forKey: sender) }
      }
      
    }
    else { self.observersKeyedName[name]?._removeNotification(name) }
    
    self.observersUnsorted._removeNotification(name)
    
  }
  
  //Remove notifications with the name from both sender and without sender
  func removeAllNotifications(name:String) {
    var observersKeyedName = self.observersKeyedSender.objectEnumerator().allObjects as [[String:[Notification<T>]]]
    var keys = self.observersKeyedSender.keyEnumerator().allObjects as [AnyObject]
    
    var notificationsToRemove:[Notification<T>]?
    
    for key in keys {
      var pairs = self.observersKeyedSender.objectForKey(key) as [String:[Notification<T>]]?
      if var pairs = pairs {
        notificationsToRemove = pairs.removeValueForKey(name)
        if pairs.isEmpty { self.observersKeyedSender.removeObjectForKey(key) }
      }
    }
    
    if let moreNotificationsToRemove = self.observersKeyedName.removeValueForKey(name) {

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
  
  func removeAllNotifications(sender:AnyObject) {
    
  }


  
}


