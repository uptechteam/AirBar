//
//  GestureStateObservable.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal class GestureStateObservable: Observable<UIGestureRecognizerState> {
  private weak var gestureRecognizer: UIGestureRecognizer?
  
  internal init(gestureRecognizer: UIGestureRecognizer) {
    self.gestureRecognizer = gestureRecognizer
    super.init()
    
    gestureRecognizer.addTarget(self, action: #selector(self.handleEvent(_:)))
  }
  
  deinit {
    gestureRecognizer?.removeTarget(self, action: #selector(self.handleEvent(_:)))
  }
  
  @objc private func handleEvent(_ recognizer: UIGestureRecognizer) {
    observer?(recognizer.state)
  }
}
