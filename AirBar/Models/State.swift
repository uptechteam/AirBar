//
//  State.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 7/4/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

public struct State {
  internal let offset: CGFloat
  internal let isExpandedStateAvailable: Bool
  internal let configuration: Configuration

  internal init(offset: CGFloat, isExpandedStateAvailable: Bool, configuration: Configuration) {
    self.offset = offset
    self.isExpandedStateAvailable = isExpandedStateAvailable
    self.configuration = configuration
  }

  internal func stateRange() -> StateRange {
    if offset > -configuration.normalStateHeight {
      return .compactNormal
    } else {
      return .normalExpanded
    }
  }

  internal func set(offset: CGFloat) -> State {
    return State(
      offset: offset,
      isExpandedStateAvailable: isExpandedStateAvailable,
      configuration: configuration
    )
  }

  internal func add(offset: CGFloat) -> State {
    return set(offset: self.offset + offset)
  }

  internal func set(isExpandedStateAvailable: Bool) -> State {
    return State(
      offset: offset,
      isExpandedStateAvailable: isExpandedStateAvailable,
      configuration: configuration
    )
  }
}

public extension State {
  public func height() -> CGFloat {
    return -offset
  }

  public func transitionProgress() -> CGFloat {
    let stateRange = self.stateRange()
    let offsetBounds = configuration.offsetBounds(for: stateRange)
    let progressBounds = stateRange.progressBounds()
    let reversedProgressBounds = (progressBounds.1, progressBounds.0)
    return offset.map(from: offsetBounds, to: reversedProgressBounds)
  }

  public enum ValueRangeType {
    case value(CGFloat)
    case range(CGFloat, CGFloat)

    internal var range: (CGFloat, CGFloat) {
      switch self {
      case let .value(value):
        return (value, value)
      case let .range(range):
        return range
      }
    }
  }

  public func value(compactNormalRange: ValueRangeType, normalExpandedRange: ValueRangeType) -> CGFloat {
    let progress = self.transitionProgress()
    let stateRange = self.stateRange()
    let valueRange = stateRange == .compactNormal ? compactNormalRange : normalExpandedRange
    return progress.map(from: stateRange.progressBounds(), to: valueRange.range)
  }
}

extension State: Equatable {
  public static func == (lhs: State, rhs: State) -> Bool {
    return lhs.offset == rhs.offset &&
      lhs.configuration == rhs.configuration
  }
}
