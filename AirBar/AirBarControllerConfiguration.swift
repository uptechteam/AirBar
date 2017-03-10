//
//  AirBarControllerConfiguration.swift
//  AirBar
//
//  Created by Evgeny Matviyenko on 2/26/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import Foundation

public struct AirBarControllerConfiguration {
  public let normalStateHeight: CGFloat
  public let compactStateHeight: CGFloat?
  public let expandedStateHeight: CGFloat?
  public let initialState: AirBarState

  /// Initializes AirBarController configuration object.
  /// Configuration must provide state height for selected initial state.
  /// All state heights must be greater then zero.
  /// Normal state height must be greater then compact state height and expanded state height must be greater then normal state height.
  ///
  /// - Parameters:
  ///   - normalStateHeight: Height of AirBarController normal state.
  ///   - compactStateHeight: Height of AirBarController compact state. Optional. Default is nil.
  ///   - expandedStateHeight: Height of AirBarController expanded state. Optional. Default is nil
  ///   - initialState: AirBarController initial state.
  public init(
    normalStateHeight: CGFloat,
    compactStateHeight: CGFloat? = nil,
    expandedStateHeight: CGFloat? = nil,
    initialState: AirBarState = .normal
    ) {
    self.normalStateHeight = normalStateHeight
    self.compactStateHeight = compactStateHeight
    self.expandedStateHeight = expandedStateHeight
    self.initialState = initialState
  }

  func height(for state: AirBarState) -> CGFloat? {
    switch state {
    case .normal:
      return normalStateHeight
    case .compact:
      return compactStateHeight
    case .expanded:
      return expandedStateHeight
    }
  }
}
