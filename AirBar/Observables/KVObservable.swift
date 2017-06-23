//
//  KVOContextObservable.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

class KVObservable<Value>: Observable {
  private let keyPath: String
  private let object: AnyObject
  
  init(keyPath: String, object: AnyObject) {
    self.keyPath = keyPath
    self.object = object
  }
  
  func subscribe(onNext: @escaping (Value) -> Void) -> Subscription {
    let observer = KVObserver<Value>(observe: onNext)
    let object = self.object
    let keyPath = self.keyPath
    var context = NSUUID().uuidString
    
    object.addObserver(observer, forKeyPath: keyPath, options: [.new], context: &context)
    
    return Subscription(dispose: {
      object.removeObserver(observer, forKeyPath: keyPath, context: &context)
    })
  }
}

private class KVObserver<Value>: NSObject {
  private let observe: (Value) -> Void
  
  init(observe: @escaping (Value) -> Void) {
    self.observe = observe
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let newValue = change?[NSKeyValueChangeKey.newKey] as? Value else { return }
    observe(newValue)
  }
}
