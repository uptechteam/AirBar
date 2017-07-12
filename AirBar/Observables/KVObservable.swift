//
//  KVOContextObservable.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal class KVObservable<Value>: Observable<Value> {
  private let keyPath: String
  private weak var object: AnyObject?
  private var observingContext = NSUUID().uuidString
  
  internal init(keyPath: String, object: AnyObject) {
    self.keyPath = keyPath
    self.object = object
    super.init()
    
    object.addObserver(self, forKeyPath: keyPath, options: [.new], context: &observingContext)
  }
  
  deinit {
    object?.removeObserver(self, forKeyPath: keyPath, context: &observingContext)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard
      context == &observingContext,
      let newValue = change?[NSKeyValueChangeKey.newKey] as? Value
    else {
      return
    }

    observer?(newValue)
  }
}
