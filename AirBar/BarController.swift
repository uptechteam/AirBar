//
//  BarController.swift
//  AirBar
//
//  Created by Евгений Матвиенко on 6/23/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import UIKit

public class BarController {
  // MARK: Private Properties
  private let stateReducer: StateReducer
  private let configuration: BarConfiguration
  private let stateObserver: (CGFloat) -> Void
  
  private weak var scrollable: Scrollable?
  private var contentOffsetObservable: Observable<CGPoint>?
  private var contentSizeObservable: Observable<CGSize>?
  private var panGestureStateObservable: Observable<UIGestureRecognizerState>?
  
  private var state: CGFloat = 1 {
    didSet {
      stateObserver(state)
    }
  }
  
  // MARK: - Lifecycle
  internal init(
    stateReducer: @escaping StateReducer,
    configuration: BarConfiguration,
    stateObserver: @escaping (CGFloat) -> Void
  ) {
    self.stateReducer = stateReducer
    self.configuration = configuration
    self.stateObserver = stateObserver
  }
  
  public convenience init(
    configuration: BarConfiguration,
    stateObserver: @escaping (CGFloat) -> Void
    ) {
    let middlewares = [ignoreTopDeltaYMiddleware, ignoreBottomDeltaYMiddleware]
    let stateReducer = createDefaultStateReducer(middlewares: middlewares)

    self.init(
      stateReducer: stateReducer,
      configuration: configuration,
      stateObserver: stateObserver
    )
  }
  
  // MARK: - Public Methods
  public func set(scrollView: UIScrollView) {
    self.set(scrollable: scrollView)
  }
  
  internal func set(scrollable: Scrollable) {
    self.scrollable = scrollable
    self.contentOffsetObservable = scrollable.contentOffsetObservable
    self.contentSizeObservable = scrollable.contentSizeObservable
    self.panGestureStateObservable = scrollable.panGestureStateObservable

    configureScrollable(scrollable)
    setupObserving()
  }
  
  // MARK: - Private Methods
  private func setupObserving() {
    // Content offset observing.
    var previousContentOffset: CGPoint?
    contentOffsetObservable?.observer = { [weak self] contentOffset in
      let contentOffset = CGPoint(x: contentOffset.x, y: contentOffset.y.rounded(.toNearestOrEven))
      self?.contentOffsetChanged(previousValue: previousContentOffset, newValue: contentOffset)
      previousContentOffset = contentOffset
    }
    
    // Content size observing.
    var previousContentSize: CGSize?
    contentSizeObservable?.observer = { [weak self] contentSize in
      self?.contentSizeChanged(previousValue: previousContentSize, newValue: contentSize)
      previousContentSize = contentSize
    }
    
    // Pan gesture state observing.
    panGestureStateObservable?.observer = { [weak self] state in
      self?.panGestureStateChanged(state: state)
    }
  }
  
  private func contentOffsetChanged(previousValue: CGPoint?, newValue: CGPoint) {
    guard
      let previousValue = previousValue,
      let scrollable = scrollable
    else {
      return
    }

    print(scrollable.contentInset)
    print(scrollable.contentOffset)

    let reducerParams = StateReducerParameters(
      scrollable: scrollable,
      configuration: configuration,
      previousContentOffset: previousValue,
      contentOffset: newValue,
      state: state
    )

    state = stateReducer(reducerParams)
  }
  
  private func contentSizeChanged(previousValue: CGSize?, newValue: CGSize) {
    guard let scrollable = scrollable else { return }
    configureScrollable(scrollable)
  }
  
  private func panGestureStateChanged(state: UIGestureRecognizerState) {
    switch state {
    case .ended:
      panGestureEnded()
    default:
      break
    }
  }

  private func panGestureEnded() {
    guard let scrollable = scrollable else { return }

    let currentState = state
    let roundedState = currentState.rounded(.toNearestOrEven)

    guard currentState != roundedState else { return }

    let stateRange: (AirBarState, AirBarState)
    if currentState < 1 {
      stateRange = (.compact, .normal)
    } else {
      stateRange = (.normal, .expanded)
    }

    let stateDelta = roundedState - currentState
    let heightDelta = configuration.height(for: stateRange.1) - configuration.height(for: stateRange.0)
    let offsetDelta = stateDelta.map(from: (-1, 1), to: (-heightDelta, heightDelta))
    let targetContentOffsetY = scrollable.contentOffset.y - offsetDelta
    let targetContentOffset = CGPoint(x: scrollable.contentOffset.x, y: targetContentOffsetY)

    scrollable.updateContentOffset(targetContentOffset, animated: true)
  }

  private func configureScrollable(_ scrollable: Scrollable) {
    scrollable.updateTopContentInset(configuration.expandedStateHeight)

    // Make sure that bar always expands and concats.
    let targetBottomContentInset: CGFloat
    if scrollable.contentSize.height < scrollable.frame.height - configuration.compactStateHeight {
      targetBottomContentInset = scrollable.frame.height - configuration.compactStateHeight - scrollable.contentSize.height
    } else {
      targetBottomContentInset = 0
    }

    scrollable.updateBottomContentInset(targetBottomContentInset)
  }
}
