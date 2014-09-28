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
  
  init() {
    
  }
  
  final private func observersForPredicateTarget(target:AnyObject) -> [String:[Notification]]? {
    return self.observersKeyedSender.objectForKey(target) as [String:[Notification]]?
  }
  func addObserverForName(name: String, sender: AnyObject?, usingBlock block: (Notification) -> Void) -> Notification {
    let notification = Notification(name: name, sender: sender, closure: block)
    if let target: AnyObject = sender {
      if var observersForTarget = self.observersForPredicateTarget(target)?[name] {
        observersForTarget.append(notification)
      }
      else {
        var observers = [name:[notification]]
        self.observersKeyedSender.setObject(observers, forKey: target)
      }
      
    }
    else {
      if var list = self.observersKeyedName[name] { list.append(notification) }
      else { self.observersKeyedName[name] = [notification] }
    }

    self.observers.append(notification)
    return notification
  }
  

  func postNotification(notification: Notification) {
    if let not = (self.observers.filter { $0 === notification }).first { not.execute() }
  }
  
  func postNotificationName(name: String, sender: AnyObject?) {
    if let sender: AnyObject = sender {
      var observersKeyedName = self.observersKeyedSender.objectForKey(sender) as? [String:[Notification]]
      if let notifications = observersKeyedName?[name] {
        for notification in notifications { notification.execute() }
      }
    }
    else if let notifications = self.observersKeyedName[name] {
      for notification in notifications { notification.closure(notification) }
    }
  }
  
  func postNotificationName(aName: String, sender: AnyObject?, userInfo aUserInfo: [NSObject : AnyObject]) {
    
  }


  
}


NotificationHub.defaultHub.addObserverForName("fuck", sender: nil) { not in
  println(not.name)
  println(not.sender)
  
}
