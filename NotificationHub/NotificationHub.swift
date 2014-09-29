import Foundation
import SpriteKit

class Notification {
  typealias NotificationClosure = (Notification) -> Void
  let name:String
  private(set) weak var sender:AnyObject?
  private let closure:NotificationClosure

  init(name:String, sender:AnyObject?, closure:NotificationClosure) {
    self.name = name
    self.closure = closure
    self.sender = sender
  }
  final private func execute() {
    self.closure(self)
  }
  
}


private extension Array {
  func executeNotifications() {
    for t in self { (t as Notification).execute() }
  }
}

class NotificationHub {

  var observers = [Notification]()
  var observersKeyedName = [String:[Notification]]()
  let observersKeyedSender:NSMapTable = NSMapTable(
    keyOptions: NSPointerFunctionsOpaquePersonality|NSPointerFunctionsWeakMemory,
    valueOptions: NSPointerFunctionsStrongMemory)

  class var defaultHub : NotificationHub {
    struct Static {
      static var onceToken : dispatch_once_t = 0
      static var instance : NotificationHub? = nil
    }
    dispatch_once(&Static.onceToken) { Static.instance = NotificationHub() }
    return Static.instance!
  }
  
  init() {}
  
  final private func observersKeyedSender(sender:AnyObject) -> [String:[Notification]]? {
    return self.observersKeyedSender.objectForKey(sender) as [String:[Notification]]?
  }
  
  func addObserverForName(name: String, sender: AnyObject?, usingBlock block: (Notification) -> Void) -> Notification {
    let notification = Notification(name: name, sender: sender, closure: block)
    
    if let sender: AnyObject = sender {
      if var observers = self.observersKeyedSender(sender)?[name] { observers.append(notification) }
      else { self.observersKeyedSender.setObject([name:[notification]], forKey: sender) }
      
    }
    else {
      if var list = self.observersKeyedName[name] { list.append(notification) }
      else { self.observersKeyedName[name] = [notification] }
    }

    self.observers.append(notification)
    return notification
  }
  

  func postNotification(notification: Notification) {
    if let n = (self.observers.filter { $0 === notification }).first { n.execute() }
  }
  
  func postNotificationName(name: String, sender: AnyObject?) {
    if let sender: AnyObject = sender {
      let observersKeyedName = self.observersKeyedSender.objectForKey(sender) as? [String:[Notification]]
      observersKeyedName?[name]?.executeNotifications()
      
    }
    else { self.observersKeyedName[name]?.executeNotifications() }
  }
  
  func removeNotification(notification: Notification) {
    let sender: AnyObject? = notification.sender
    let name = notification.name
    
    if let sender: AnyObject = sender {
      if var observers = self.observersKeyedSender(sender)?[name] { observers.append(notification) }
      else { self.observersKeyedSender.setObject([name:[notification]], forKey: sender) }
      
    }
    else {
      if var list = self.observersKeyedName[name] { list.append(notification) }
      else { self.observersKeyedName[name] = [notification] }
    }
    
    self.observers = self.observers.filter { $0 !== notification }
    
    
  }


  
}


