//
//  State.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/4/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

public struct State {
  let height: CGFloat
  internal let configuration: Configuration

  internal init(height: CGFloat, configuration: Configuration) {
    self.height = height
    self.configuration = configuration
  }

  internal func adding(height: CGFloat) -> State {
    return State(
      height: self.height + height,
      configuration: configuration
    )
  }

  public func stateRange() -> StateRange {
    if height < configuration.normalStateHeight {
      return .compactNormal
    } else {
      return .normalExpanded
    }
  }

  public func transitionProgress() -> CGFloat {
    switch stateRange() {
    case .compactNormal:
      return height.map(from: (configuration.compactStateHeight, configuration.normalStateHeight), to: (0, 1))
    case .normalExpanded:
      return height.map(from: (configuration.normalStateHeight, configuration.expandedStateHeight), to: (1, 2))
    }
  }
}

public enum StateRange {
  case compactNormal
  case normalExpanded
}
