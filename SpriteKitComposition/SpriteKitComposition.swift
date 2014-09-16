import SpriteKit


@objc protocol Component {
  var isEnabled:Bool { get set }
  weak var node:SKNode? { get set}
  optional func didAddToNode()
  optional func didRemoveFromNode()
  optional func didAddNodeToScene()
  optional func didRemoveNodeFromScene()

  //Cares about isEnabled
  optional func didUpdate(time:NSTimeInterval)
  optional func didChangeSceneSizedFrom(previousSize:CGSize)
  optional func didEvaluateActions()
  optional func didSimulatePhysics()
  optional func didBeginContact(contact:SKPhysicsContact)
  optional func didEndContact(contact:SKPhysicsContact)
  @availability(iOS, introduced=8.0)
  optional func didApplyConstraints()
  optional func didFinishUpdate()

  //Doesn't care about isEnabled
  optional func didMoveToView(view: SKView)
  optional func willMoveFromView(view: SKView)
  optional func didChangeSize(oldSize: CGSize)
  
}


private class InternalComponentContainer {
  var components = [String:Component]()
  var lastUpdateTimeInterval:NSTimeInterval = 0
}


extension SKNode {
  var components:[Component] { return self.componentContainer.components.values.array }
  var childNodes:[SKNode]    { return self.children as [SKNode]                       }
  
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
    let key = NSStringFromClass(theClass)
    return self.removeComponentWithKey(key)
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
  let mapTable:NSMapTable = NSMapTable(keyOptions: NSPointerFunctionsOpaquePersonality, valueOptions: NSPointerFunctionsStrongMemory)
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

 extension SKScene : SKPhysicsContactDelegate {
  public func update(currentTime: NSTimeInterval) {
    let container = self.componentContainer
    var timeSinceLast: CFTimeInterval = currentTime - container.lastUpdateTimeInterval
    container.lastUpdateTimeInterval = currentTime
    if (timeSinceLast > 1) {
      timeSinceLast = 1.0 / 60.0
      container.lastUpdateTimeInterval = currentTime
    }
    super.internalUpdate(timeSinceLast)
  }
  
  public func didEvaluateActions() {
    super.internalDidEvaluateActions()
  }

  public func didSimulatePhysics() {
    super.internalDidSimulatePhysics()
  }
  
  public func didFinishUpdate() {
    super.internalDidFinishUpdate()
  }
  
  public func didBeginContact(contact: SKPhysicsContact) {
    let componentsA = contact.bodyA.node?.components ?? [Component]()
    let componentsB = contact.bodyB.node?.components ?? [Component]()

    let allComponents = componentsA + componentsB
    println(allComponents)
    for component in allComponents { if(component.isEnabled == true) { component.didBeginContact?(contact) } }

  }
  
  public func didEndContact(contact: SKPhysicsContact) {
    let componentsA = contact.bodyA.node?.components ?? [Component]()
    let componentsB = contact.bodyB.node?.components ?? [Component]()
    let allComponents = componentsA + componentsB
    for component in allComponents {
      if(component.isEnabled == true ) {
        component.didEndContact?(contact)
      }
    }
    
  }

  
  public func didMoveToView(view: SKView) {
    self.physicsWorld.contactDelegate = self
  }

  public func willMoveFromView(view: SKView) {
    
  }



}

extension SKNode {
  
  private func internalUpdate(currentTime: NSTimeInterval) {
    for component in self.components { if(component.isEnabled) { component.didUpdate?(currentTime) } }
    for child in self.childNodes     { child.internalUpdate(currentTime) }
  }

  private func internalDidEvaluateActions() {
    for component in self.components { if(component.isEnabled) { component.didEvaluateActions?() } }
    for child in self.childNodes     { child.internalDidEvaluateActions()  }
  }
  
  private func internalDidSimulatePhysics() {
    for component in self.components { if(component.isEnabled) { component.didSimulatePhysics?() } }
    for child in self.childNodes     { child.internalDidSimulatePhysics()  }
  }
  
  private func internalDidFinishUpdate() {
    for component in self.components { if(component.isEnabled) { component.didFinishUpdate?() } }
    for child in self.childNodes     { child.internalDidFinishUpdate()  }
    
  }

  
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
    var nodesAsSKNodes = nodes as [SKNode]
    var childNodesToRemove = [SKNode]()
    for child in self.childNodes {
      if(contains(nodesAsSKNodes, child)) {
        childNodesToRemove.append(child)
        self.removedChild(child)
      }
    }
    self.internalRemoveChildrenInArray(childNodesToRemove)
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
//      println(SharedComponentManager.sharedInstance.mapTable.count)
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



