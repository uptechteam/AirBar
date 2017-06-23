//
//  Observable.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

internal protocol Observable {
  associatedtype Value
  func subscribe(onNext: @escaping (Value) -> Void) -> Subscription
}
