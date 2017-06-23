//
//  SubscriptionBag.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

class SubscriptionBag {
  private var subscriptions = [Subscription]()
  
  func add(subscription: Subscription) {
    subscriptions.append(subscription)
  }
}
