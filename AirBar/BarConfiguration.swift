//
//  BarConfiguration.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

public struct Configuration {
  let compactStateHeight: CGFloat
  let normalStateHeight: CGFloat
  let expandedStateHeight: CGFloat
  
  public init(
    compactStateHeight: CGFloat,
    normalStateHeight: CGFloat,
    expandedStateHeight: CGFloat
    ) {
    self.compactStateHeight = compactStateHeight
    self.normalStateHeight = normalStateHeight
    self.expandedStateHeight = expandedStateHeight
  }
  
  internal func height(for state: AirBarState) -> CGFloat {
    switch state {
    case .compact:
      return compactStateHeight
    case .normal:
      return normalStateHeight
    case .expanded:
      return expandedStateHeight
    }
  }
}
