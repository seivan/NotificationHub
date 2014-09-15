import SpriteKit
let emptyArray = [String]()


@objc protocol Component {
  var isEnabled:Bool { get set }
  weak var node:SKNode? { get set}
  optional func didAddToNode()
  optional func didRemoveFromNode()
  optional func didAddNodeToScene()
  optional func didRemoveNodeFromScene()
  optional func didUpdate(time:NSTimeInterval)
  optional func didChangeSceneSizedFrom(previousSize:CGSize)
  optional func didEvaluateActions()
  optional func didSimulatePhysics()
  optional func didBeginContact(contact:SKPhysicsContact)
  optional func didEndContact(contact:SKPhysicsContact)
  
}


private class InternalComponentContainer {
  var components = [String:Component]()
}


extension SKNode {
  var components:[Component] { return self.componentContainer.components.values.array }
  var childNodes:[SKNode] { return self.children as [SKNode] }
  
  func componentWithClass(theClass:AnyClass) -> Component? {
    return self.componentContainer.components[NSStringFromClass(theClass)]
  }
  
  func componentWithKey(key:String) -> Component? {
    return self.componentContainer.components[key]
  }
  func addComponent<T:Component>(component:T, withKey key:String) -> Bool {
    if(self.componentContainer.components[key] == nil) {
      self.componentContainer.components[key] = component
      component.node = self
      component.isEnabled = true
      component.didAddToNode?()
      return true
    }
    else { return false }
  }
  
  func addComponent<T:Component>(component:T) -> Bool {
    let key = NSStringFromClass(component.dynamicType)
    return self.addComponent(component, withKey: key)
  }
  
  func removeComponentWithClass(theClass:AnyClass) -> Bool {
    return self.removeComponentWithKey(NSStringFromClass(theClass))
  }
  
  func removeComponentWithKey(key:String) -> Bool {
    if let componentToRemove = self.componentContainer.components.removeValueForKey(key) {
      componentToRemove.isEnabled = false
      componentToRemove.node = nil
      componentToRemove.didRemoveFromNode?()
      return true
    }
    else { return false }
  }
  
  func removeComponent<T:Component>(component:T) -> Bool {
    var foundKey:String?
    for (key, value) in self.componentContainer.components {
      if(value === component) {
        foundKey = key
        break
      }
    }
    if let key = foundKey { return self.removeComponentWithKey(key) }
    else { return false }
  }
  
}

private class SharedComponentManager {
  let mapTable:NSMapTable = NSMapTable.weakToStrongObjectsMapTable()
  class var sharedInstance : SharedComponentManager {
  struct Static {
    static var onceToken : dispatch_once_t = 0
    static var instance : SharedComponentManager? = nil
    }
    dispatch_once(&Static.onceToken) {
      func swizzleExchangeMethodsOnClass(cls: AnyClass, replaceSelector fromSelector:String, withSelector toSelector:String) {
        var originalMethod: Method?
        var swizzledMethod: Method?
        
        originalMethod = class_getInstanceMethod(SKNode.classForCoder(), Selector.convertFromStringLiteral(fromSelector))
        swizzledMethod = class_getInstanceMethod(SKNode.classForCoder(), Selector.convertFromStringLiteral(toSelector))
        
        if (originalMethod != nil && swizzledMethod != nil) { method_exchangeImplementations(originalMethod!, swizzledMethod!) }
        
      }
      swizzleExchangeMethodsOnClass(SKNode.self, replaceSelector: "addChild:", withSelector:"internalAddChild:")
      swizzleExchangeMethodsOnClass(SKNode.self, replaceSelector: "insertChild:atIndex:", withSelector:"internalInsertChild:atIndex:")
      swizzleExchangeMethodsOnClass(SKNode.self, replaceSelector: "removeChildrenInArray:", withSelector:"internalRemoveChildrenInArray:")
      swizzleExchangeMethodsOnClass(SKNode.self, replaceSelector: "removeAllChildren", withSelector:"internalRemoveAllChildren")
      swizzleExchangeMethodsOnClass(SKNode.self, replaceSelector: "removeFromParent", withSelector:"internalRemoveFromParent")
      
      Static.instance = SharedComponentManager()
    }
    return Static.instance!
  }
}

extension SKNode {
  
  private func addedChild(node:SKNode) {
    if self is SKScene {
      for component in node.components { component.didAddNodeToScene?() }
      for childNode in node.childNodes { node.addedChild(childNode) }
    }
    else if(self.parent != nil) {
      for component in node.components { component.didAddNodeToScene?() }
      for childNode in node.childNodes { node.addedChild(childNode) }
    }
  }
  
  
  
  func internalAddChild(node:SKNode!) {
    if(node.parent != self) {
      node.removeFromParent()
      self.internalAddChild(node)
      self.addedChild(node);
    }
    
  }
  
  func internalInsertChild(node: SKNode!, atIndex index: Int) {
    if(node.parent != self) {
      node.removeFromParent()
      self.internalInsertChild(node, atIndex: index)
      self.addedChild(node);
    }
    
  }
  
  private func removedChild(node:SKNode) {
    if self is SKScene {
      for component in node.components { component.didRemoveNodeFromScene?() }
      for childNode in node.childNodes { node.removedChild(childNode) }
    }
    else if(self.parent != nil) {
      for component in node.components { component.didRemoveNodeFromScene?() }
      for childNode in node.childNodes { node.removedChild(childNode) }
    }
    
  }
  
  
  func internalRemoveChildrenInArray(nodes: [AnyObject]!) {
    var deletion = [SKNode]()
    for child in self.childNodes {
      if(contains(nodes as [SKNode], child)) {
        self.removedChild(child)
      }
    }
    self.internalRemoveChildrenInArray(nodes)
  }
  
  func internalRemoveAllChildren() {
    for child in self.childNodes { self.removedChild(child) }
    self.internalRemoveAllChildren()
  }
  
  func internalRemoveFromParent() {
    self.parent?.removedChild(self)
    self.internalRemoveFromParent()
    
  }
  
  
  
  private var componentContainer:InternalComponentContainer {
    get {
      var manager = SharedComponentManager.sharedInstance.mapTable.objectForKey(self) as InternalComponentContainer?
      if(manager == nil) {
        manager = InternalComponentContainer()
        SharedComponentManager.sharedInstance.mapTable.setObject(manager!, forKey: self)
      }
      return manager!
    }
    
    //    get {
    //      var manager = objc_getAssociatedObject(self, &AssociatedKeyComponentManager) as ComponentManager?
    //      if(manager == nil) {
    //          manager = ComponentManager()
    //          objc_setAssociatedObject(self, &AssociatedKeyComponentManager, manager, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    //        }
    //      return manager!
    //    }
  }
  
}

