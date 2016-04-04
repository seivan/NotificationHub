import Foundation

final public class Notification<T>  {
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
    static var hub = NotificationHub<[String:Any]>()
}



final public class NotificationHub<T>  {
    final private(set) var notifications    =  [String: [Notification<T>]]()
    
    final private var allNotifications:[Notification<T>] {
        return self.notifications.values.flatMap { return $0 }
    }
    

    class var defaultHub:NotificationHub<[String:Any]> { return Static.hub }

    init() {}
    
    
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
        if var notifications = self.notifications[name] {
            notifications.append(notification)
            self.notifications[name] =  notifications
        }
        else {

            self.notifications[name] = [notification]
        }
        
        return notification
    }
    
    
    func publishNotificationName(name: String, sender: AnyObject? = nil, userInfo:T? = nil) -> Bool {
        #if DEBUG
            NotificationHubMock.onPublishMockHandler?(name: name, sender: sender, userInfo: userInfo)
        #endif
        
        
        var didPublish = false
        if let notifications = self.notifications[name] {
            
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
        
        guard notification.hub == self else { return false }
        
        let name = notification.name
        guard var notifications = self.notifications[name] else { return false}
        guard let index = notifications.indexOf(notification) else { return false }
        notifications.removeAtIndex(index)
        
        
        if notifications.count == 0  { self.notifications[name] = nil }
        else { self.notifications[name] = notifications }
        notification.hub = nil
        
        
        return true
    }
    
    func removeNotificationsName(name:String, sender: AnyObject? = nil) -> Bool {
        
        #if DEBUG
            NotificationHubMock.onRemoveMockHandler?(name:name, sender:sender)
        #endif
        
        guard let notifications = self.notifications[name] else { return false}
        let preCount = notifications.count
        

        let filteredNotifications = notifications.filter { not -> Bool in
            guard not.sender == nil || not.sender === sender else { return true  }
            not.hub = nil
            return false
        }
        
        
        
        let postCount = filteredNotifications.count
        if postCount == 0 { self.notifications[name] = nil }
        else { self.notifications[name] = filteredNotifications }
        
        return preCount != postCount
        
    }
    
    func removeAllNotificationsName(name:String) -> Bool {
        #if DEBUG
            NotificationHubMock.onRemoveMockHandler?(name:name, sender:nil)
        #endif
        
        let preCount = self.notifications.count
        guard let notifications = self.notifications[name] else { return false }
        self.notifications[name] = nil
        
        notifications.forEach { (notification) -> () in
            notification.hub = nil
        }
        let postCount = self.notifications.count
        return preCount != postCount
    }
    
    func removeAllNotificationsSender(sender:AnyObject) -> Bool {
        #if DEBUG
            NotificationHubMock.onRemoveMockHandler?(name:nil, sender:sender)
        #endif
        
        let count = self.notifications.count
        let notifications = self.allNotifications

        
        
        notifications.forEach { (notification) -> () in
            if notification.sender === sender { notification.remove() }
        }

        
        self.notifications.removeAll()
        return count > 0
    }
    
    
    
    func removeAllNotifications() -> Bool {
        #if DEBUG
            NotificationHubMock.onRemoveMockHandler?(name:nil, sender:nil)
        #endif
        
        let count = self.notifications.count
        let notifications = self.allNotifications
        
        self.notifications.removeAll()
        
        notifications.forEach { notification in
            notification.hub = nil
        }
        
        return count > 0
    }
}


extension Notification : Equatable {}
public func ==<T>(lhs: Notification<T>, rhs: Notification<T>) -> Bool { return lhs === rhs }

extension NotificationHub : Equatable {}
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
