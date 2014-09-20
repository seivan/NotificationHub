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
  optional func didEvaluateActions()
  optional func didSimulatePhysics()
  optional func didApplyConstraints()
  optional func didFinishUpdate()

  optional func didBeginContactWithNode(node:SKNode, contact:SKPhysicsContact)
  optional func didEndContactWithNode(node:SKNode, contact:SKPhysicsContact)
  
  optional func didBeginContact(contact:SKPhysicsContact)
  optional func didEndContact(contact:SKPhysicsContact)

  optional func touchesBegan(touches: [UITouch], withEvent event: UIEvent)

  //Doesn't care about isEnabled
  optional func didChangeSceneSizedFrom(previousSize:CGSize)
  optional func didMoveToView(view: SKView)
  optional func willMoveFromView(view: SKView)
  optional func didChangeSize(oldSize: CGSize)
  
}


final private class InternalComponentContainer {
  var components = [String:Component]()
  var lastUpdateTimeInterval:NSTimeInterval = 0
}


extension SKNode {
  final var components:[Component] { return self.componentContainer.components.values.array }
  final var childNodes:[SKNode]    { return self.children as [SKNode]                       }
  
  final func componentWithClass(theClass:AnyClass) -> Component? {
    return self.componentContainer.components[NSStringFromClass(theClass)]
  }
  
  final func componentWithKey(key:String) -> Component? {
    return self.componentContainer.components[key]
  }
  
  final func addComponent<T:Component>(component:T, withKey key:String) -> Bool {
    if self.componentContainer.components[key] == nil {
      self.componentContainer.components[key] = component
      component.node = self
      component.isEnabled = true
      component.didAddToNode?()
      if self.scene != nil { component.didAddNodeToScene?() }
      return true
    }
    else { return false }
    
  }
  
  final func addComponent<T:Component>(component:T) -> Bool {
    let key = NSStringFromClass(component.dynamicType)
    return self.addComponent(component, withKey: key)
  }
  
  final func removeComponentWithClass(theClass:AnyClass) -> Bool {
    let key = NSStringFromClass(theClass)
    return self.removeComponentWithKey(key)
  }
  
  final func removeComponentWithKey(key:String) -> Bool {
    if let componentToRemove = self.componentContainer.components.removeValueForKey(key) {
      componentToRemove.isEnabled = false
      componentToRemove.didRemoveFromNode?()
      
      return true
    }
    else { return false }
  }
  
  final func removeComponent<T:Component>(component:T) -> Bool {
    var foundKey:String?
    for (key, value) in self.componentContainer.components {
      if value === component {
        foundKey = key
        break
      }
    }
    if let key = foundKey { return self.removeComponentWithKey(key) }
    else { return false }
  }
  
}



extension SKScene : SKPhysicsContactDelegate {
  public func update(currentTime: NSTimeInterval) {
    let container = self.componentContainer
    var timeSinceLast: CFTimeInterval = currentTime - container.lastUpdateTimeInterval
    container.lastUpdateTimeInterval = currentTime
    if  timeSinceLast > 1  {
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
  
  /* Constraints
  
  */
  
  public func didFinishUpdate() {
    super.internalDidFinishUpdate()
  }
  
  
  public func didBeginContact(contact: SKPhysicsContact) {
    super.internalDidBeginContact(contact)
  }
  
  public func didEndContact(contact: SKPhysicsContact) {
    super.internalDidEndContact(contact)
  }

  
  public func didMoveToView(view: SKView) {
    self.physicsWorld.contactDelegate = self
  }

  public func willMoveFromView(view: SKView) {
    
  }
  


}

extension SKNode {
  
  final private func internalUpdate(currentTime: NSTimeInterval) {
    for component in self.components { if component.isEnabled { component.didUpdate?(currentTime) } }
    for child in self.childNodes     { child.internalUpdate(currentTime) }
  }

  final private func internalDidEvaluateActions() {
    for component in self.components { if component.isEnabled { component.didEvaluateActions?() } }
    for child in self.childNodes     { child.internalDidEvaluateActions()  }
  }
  
  final private func internalDidSimulatePhysics() {
    for component in self.components { if component.isEnabled { component.didSimulatePhysics?() } }
    for child in self.childNodes     { child.internalDidSimulatePhysics()  }
  }
  
  /* Constraints
  
  */

  final private func internalDidFinishUpdate() {
    for component in self.components { if component.isEnabled  { component.didFinishUpdate?() } }
    for child in self.childNodes     { child.internalDidFinishUpdate()  }
    
  }

  final private func tupleForContact(contact: SKPhysicsContact) -> (allComponents: [Component], allNodes: [SKNode]) {
    let nodeA = contact.bodyA.node
    let nodeB = contact.bodyB.node
    
    let componentsA = nodeA?.components ?? [Component]()
    let componentsB = nodeB?.components ?? [Component]()
    
    let allComponents = componentsA + componentsB
    let allNodes = (nodeA?.childNodes ?? [SKNode]()) + (nodeB?.childNodes ?? [SKNode]())
    
    return (allComponents, allNodes)

  }

  final private func internalRecursiveDidBeginContact(contact: SKPhysicsContact) {
    for component in self.components { if component.isEnabled { component.didBeginContact?(contact) } }
    for child in self.childNodes     { child.internalRecursiveDidBeginContact(contact)  }
  }
  
  
  final private func internalDidBeginContact(contact: SKPhysicsContact) {
    let tupleForContact = self.tupleForContact(contact)
    for component in self.components                { if component.isEnabled { component.didBeginContact?(contact) } }
    for component in tupleForContact.allComponents  { if component.isEnabled { component.didBeginContact?(contact) } }
    for sprite    in tupleForContact.allNodes       { sprite.internalRecursiveDidBeginContact(contact) }
  }

  final private func internalRecursiveDidEndContact(contact: SKPhysicsContact) {
    for component in self.components { if component.isEnabled { component.didEndContact?(contact) } }
    for child in self.childNodes     { child.internalRecursiveDidEndContact(contact)  }
  }

  final private func internalDidEndContact(contact: SKPhysicsContact) {
    let tupleForContact = self.tupleForContact(contact)
    for component in self.components                { if component.isEnabled { component.didEndContact?(contact) } }
    for component in tupleForContact.allComponents  { if component.isEnabled { component.didEndContact?(contact) } }
    for sprite    in tupleForContact.allNodes       { sprite.internalRecursiveDidEndContact(contact) }
    
  }
  
  
  final private func internalTouchesBegan(touches: [UITouch], withEvent event: UIEvent) {
    for component in self.components { if component.isEnabled { component.touchesBegan?(touches, withEvent: event) } }
//    for child in self.childNodes     { child.internalTouchesBegan(touches, withEvent: event) }
    
  }
  
   override public func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
    let touchesList:[UITouch] = touches.allObjects as [UITouch]
    self.internalTouchesBegan(touchesList, withEvent: event)
  }

}

extension SKNode {
  
  final private func addedChild(node:SKNode) {
    if self is SKScene {
      for component in node.components { component.didAddNodeToScene?() }
      for childNode in node.childNodes { node.addedChild(childNode) }
    }
    else if self.parent != nil {
      for component in node.components { component.didAddNodeToScene?() }
      for childNode in node.childNodes { node.addedChild(childNode) }
    }
  }
  
  
  
  final func internalAddChild(node:SKNode!) {
    if node.parent != self {
      node.removeFromParent()
      self.internalAddChild(node)
      self.addedChild(node);
    }
    
  }
  
  final func internalInsertChild(node: SKNode!, atIndex index: Int) {
    if node.parent != self {
      node.removeFromParent()
      self.internalInsertChild(node, atIndex: index)
      self.addedChild(node);
    }
    
  }
  
  final private func removedChild(node:SKNode) {
    if self is SKScene {
      for component in node.components { component.didRemoveNodeFromScene?() }
      for childNode in node.childNodes { node.removedChild(childNode) }
    }
    else if self.parent != nil {
      for component in node.components { component.didRemoveNodeFromScene?() }
      for childNode in node.childNodes { node.removedChild(childNode) }
    }
    
  }
  
  
  final func internalRemoveChildrenInArray(nodes: [AnyObject]!) {
    var nodesAsSKNodes = nodes as [SKNode]
    var childNodesToRemove = [SKNode]()
    for child in self.childNodes {
      if contains(nodesAsSKNodes, child) {
        childNodesToRemove.append(child)
        self.removedChild(child)
      }
    }
    self.internalRemoveChildrenInArray(childNodesToRemove)
  }
  
  final func internalRemoveAllChildren() {
    for child in self.childNodes { self.removedChild(child) }
    self.internalRemoveAllChildren()
  }
  
  final func internalRemoveFromParent() {
    self.parent?.removedChild(self)
    self.internalRemoveFromParent()
    
  }
  
  
  
  final private var componentContainer:InternalComponentContainer {
    get {
//      println(SharedComponentManager.sharedInstance.mapTable)
      var manager = SharedComponentManager.sharedInstance.mapTable.objectForKey(self) as InternalComponentContainer?
      if manager == nil {
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

final private class SharedComponentManager {
  let mapTable:NSMapTable = NSMapTable(keyOptions: NSPointerFunctionsOpaquePersonality|NSPointerFunctionsWeakMemory, valueOptions: NSPointerFunctionsStrongMemory)
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
        
        if originalMethod != nil && swizzledMethod != nil { method_exchangeImplementations(originalMethod!, swizzledMethod!) }
        
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

