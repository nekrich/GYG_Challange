import Foundation

class AsynchronousOperation: Operation {
  
  final override var isAsynchronous: Bool {
    return true
  }
  
  private let synchronizationQueue = DispatchQueue(label: "Sync queue", attributes: .concurrent)
  
  final override var isReady: Bool {
    return state == .ready && super.isReady
  }
  
  final override var isExecuting: Bool {
    return state == .executing
  }
  
  final override var isFinished: Bool {
    return state == .finished
  }
  
  final override var isCancelled: Bool {
    return _isCancelled
  }
  
  @objc private var __isCancelled: Bool = false
  private var _isCancelled: Bool {
    get {
      return synchronizationQueue.sync { self.__isCancelled }
    }
    set {
      synchronizationQueue.async { self.__isCancelled = newValue }
    }
  }
  
  @objc
  private enum State: Int {
    
    case ready
    case executing
    case finished
  }
  
  @objc private var _state: State = .ready
  private var state: State {
    get {
      return synchronizationQueue.sync { self._state }
    }
    set {
      synchronizationQueue.async { self.state = newValue }
    }
  }
  
  // MARK: - Process
  
  final override func main() {
    guard !isCancelled else {
      state = .finished
      return
    }
    state = .executing
    startAsyncronousOperation()
  }
  
  func startAsyncronousOperation() {
    assertionFailure(
      "You should override `func startAsyncronousOperation()` in the \(type(of: self))"
    )
    finish()
  }
  
  func finish() {
    state = .finished
  }
  
  override func cancel() {
    guard !isFinished else {
      return
    }
    
    _isCancelled = true
    
    if isReady {
      finish()
    }
  }
  
  // MARK: - Key-Value
  
  override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
    let affectingKeyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
    switch key {
    case "isReady",
         "isExecuting",
         "isFinished":
      return affectingKeyPaths.union([#keyPath(_state)])
    case "isCancelled":
      return affectingKeyPaths.union([#keyPath(__isCancelled)])
    default:
      return affectingKeyPaths
    }
  }
}
