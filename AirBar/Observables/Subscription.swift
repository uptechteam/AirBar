//
//  Subscription.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

class Subscription {
  private let dispose: () -> Void
  
  init(dispose: @escaping () -> Void) {
    self.dispose = dispose
  }
  
  deinit {
    dispose()
  }
  
  func disposed(by bag: SubscriptionBag) {
    bag.add(subscription: self)
  }
}
