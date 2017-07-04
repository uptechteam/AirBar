//
//  AirBarController.swift
//  AirBar
//
//  Created by Evgeny Matviyenko on 2/24/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

/*import UIKit

public protocol AirBarControllerDelegate: class {
  /// Delegate method is called when AirBarController changes its internal state.
  /// You should implement this method and do all view changes according to state and height arguments.
  /// State is >= 0 and <= 2, where 0 is compact state, 1 is normal state and 2 is expanded state.
  ///
  /// - Parameters:
  ///   - controller: AirBarController object.
  ///   - state: AirBarController internal state.
  ///   - height: AirBarController recommended view height.
  func airBarController(_ controller: AirBarController, didChangeStateTo state: CGFloat, withHeight height: CGFloat)
}

public class AirBarController: NSObject {

  // MARK: - Public Properties

  /// AirBarController delegate object. Sends initial state value on didSet, so consider setting delegate after loading views.
  public weak var delegate: AirBarControllerDelegate? {
    didSet {
      // Send initial values.
      informDelegateAboutStateChanges()
    }
  }

  public weak var scrollView: UIScrollView? {
    didSet {
      if let oldScrollView = oldValue {
        removeObserving(scrollView: oldScrollView)
      }

      if let newScrollView = scrollView {
        configure(scrollView: newScrollView)
      }
    }
  }

  // MARK: - Private Properties

  private var state = AirBarState.normal.rawValue {
    didSet {
      guard state != oldValue else {
        return
      }

      informDelegateAboutStateChanges()
    }
  }

  private let configuration: AirBarControllerConfiguration
  private var previousYOffset: CGFloat?
  private var currentExpandedStateAvailability = false
  private var firstScrollViewConfigured = false

  // KVO context.
  private var observerContext = 0

  // MARK: - Lifecycle

  /// Initializes AirBarController object.
  ///
  /// - Parameters:
  ///   - configuration: AirBarControllerConfiguration object.
  public init(configuration: AirBarControllerConfiguration) {
    self.configuration = configuration

    super.init()

    // AirBarControllerConfiguration preconditions.

    precondition(configuration.normalStateHeight > 0, "Normal state height must be greater then zero.")
    precondition(configuration.height(for: configuration.initialState) != nil, "Height for initial state must be provided.")

    if let expandedStateHeight = configuration.expandedStateHeight {
      precondition(expandedStateHeight > 0, "Expanded state height must be greater then zero.")
      precondition(expandedStateHeight > configuration.normalStateHeight, "Expanded state height must be greater then normal state height.")
    }

    if let compactStateHeight = configuration.compactStateHeight {
      precondition(compactStateHeight > 0, "Compact state height must be greater then zero.")
      precondition(compactStateHeight < configuration.normalStateHeight, "Compact state height must be lower then normal state height.")
    }
  }

  deinit {
    if let scrollView = scrollView {
      removeObserving(scrollView: scrollView)
    }
  }

  // MARK: - Public Methods

  /// Expands or concats AirBarController.
  ///
  /// - Parameter on: Determines to expand or concat.
  public func expand(on: Bool) {
    guard
      let expandedStateHeight = configuration.expandedStateHeight
    else {
      return
    }

    currentExpandedStateAvailability = true
    setContentOffsetY(on ? -expandedStateHeight : -configuration.normalStateHeight)
  }

  // MARK: - Internal Helpers

  private func panGestureBegan() {
    guard let scrollView = scrollView else { return }

    let shouldInitialExpand = configuration.expandedStateHeight != nil && scrollView.contentOffset.y.isNear(to: -configuration.normalStateHeight, delta: 2)
    let shouldContinueExpand = currentExpandedStateAvailability && scrollView.contentOffset.y <= -configuration.normalStateHeight

    currentExpandedStateAvailability = shouldInitialExpand || shouldContinueExpand

    if
      currentExpandedStateAvailability,
      let expandedStateHeight = configuration.expandedStateHeight
    {
      scrollView.topContentInset = expandedStateHeight
    } else {
      scrollView.topContentInset = configuration.normalStateHeight
    }
  }

  private func panGestureEnded() {
    guard let scrollView = scrollView else { return }

    let stateRemainder = state.truncatingRemainder(dividingBy: 1)

    if
      stateRemainder != 0
    {
      let stateHeightDelta: CGFloat?

      if
        state > AirBarState.normal.rawValue,
        let expandedStateHeight = configuration.expandedStateHeight
      {
        stateHeightDelta = expandedStateHeight - configuration.normalStateHeight
      } else if let compactStateHeight = configuration.compactStateHeight {
        stateHeightDelta = configuration.normalStateHeight - compactStateHeight
      } else {
        stateHeightDelta = nil
      }

      if let stateHeightDelta = stateHeightDelta {
        let yOffsetDelta: CGFloat
        if stateRemainder < 0.5 {
          yOffsetDelta = stateHeightDelta * stateRemainder
        } else {
          yOffsetDelta = -stateHeightDelta * (1 - stateRemainder)
        }

        setContentOffsetY(scrollView.contentOffset.y + yOffsetDelta)
      }
    }
  }

  private func scrollViewContentOffsetChanged() {
    guard
      let scrollView = scrollView
    else {
      return
    }

    if
      currentExpandedStateAvailability,
      scrollView.contentOffset.y < -configuration.normalStateHeight,
      let expandedStateHeight = configuration.expandedStateHeight
    {
      // Normal - Expanded.

      state = scrollView.contentOffset.y
        .map(
          from: (-expandedStateHeight, -configuration.normalStateHeight),
          to: (AirBarState.expanded.rawValue, AirBarState.normal.rawValue)
        )
        .bounded(by: (AirBarState.normal.rawValue, AirBarState.expanded.rawValue))

      return 
    }

    // Compact - Normal.

    if
      let previousYOffset = previousYOffset,
      let compactStateHeight = configuration.compactStateHeight
    {
      var deltaY = previousYOffset - scrollView.contentOffset.y

      let start = -scrollView.contentInset.top
      if previousYOffset < start {
        if deltaY < 0 {
          deltaY = min(0, deltaY - (previousYOffset - start))
        }
      }

      let end = (scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom - CGFloat(0.5)).rounded(.down)
      if previousYOffset > end && deltaY > 0 {
        deltaY = max(0, deltaY - previousYOffset + end)
      }

      let compactNormalDelta = configuration.normalStateHeight - compactStateHeight
      let stateDelta = AirBarState.normal.rawValue - AirBarState.compact.rawValue
      let deltaState = deltaY.map(from: (-compactNormalDelta, compactNormalDelta), to: (-stateDelta, stateDelta))
      let newState = state + deltaState
      state = newState.bounded(by: (AirBarState.compact.rawValue, AirBarState.normal.rawValue))
    } else {
      state = AirBarState.normal.rawValue
    }

    previousYOffset = scrollView.contentOffset.y
  }

  private func scrollViewContentSizeChanged() {
    guard let scrollView = scrollView else { return }

    if scrollView.contentSize.height < scrollView.frame.height - (configuration.compactStateHeight ?? configuration.normalStateHeight) {
      scrollView.bottomContentInset = scrollView.frame.height - (configuration.compactStateHeight ?? configuration.normalStateHeight) - scrollView.contentSize.height
    } else {
      scrollView.bottomContentInset = 0
    }
  }

  private func setContentOffsetY(_ y: CGFloat, animated: Bool = true) {
    guard let scrollView = scrollView else { return }

    // Stop native deceleration. 
    scrollView.setContentOffset(scrollView.contentOffset, animated: false)

    let animate = {
      scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: y)
    }

    guard animated else {
      animate()
      return
    }

    UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: animate, completion: nil)
  }

  // MARK: - Delegate Helpers

  private func informDelegateAboutStateChanges() {
    let currentHeight: CGFloat

    if
      state > AirBarState.normal.rawValue,
      let expandedStateHeight = configuration.expandedStateHeight
    {
      // Normal - Expanded
      currentHeight = state.map(from: (AirBarState.normal.rawValue, AirBarState.expanded.rawValue), to: (configuration.normalStateHeight, expandedStateHeight))
    } else if let compactStateHeight = configuration.compactStateHeight {
      // Compact - Normal
      currentHeight = state.map(from: (AirBarState.compact.rawValue, AirBarState.normal.rawValue), to: (compactStateHeight, configuration.normalStateHeight))
    } else {
      // Normal
      currentHeight = configuration.normalStateHeight
    }

    delegate?.airBarController(self, didChangeStateTo: state, withHeight: currentHeight)
  }

  // MARK: - User Interaction

  @objc private func handleScrollViewPanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      panGestureBegan()
    case .ended:
      panGestureEnded()
    default:
      break
    }
  }

  // MARK: - KVO

  override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard
      context == &observerContext
    else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
      return
    }

    if keyPath == #keyPath(UIScrollView.contentOffset) {
      scrollViewContentOffsetChanged()
    } else if keyPath == #keyPath(UIScrollView.contentSize) {
      scrollViewContentSizeChanged()
    }
  }

  // MARK: - Scroll view
  private func configure(scrollView: UIScrollView) {
    scrollView.panGestureRecognizer.addTarget(self, action: #selector(handleScrollViewPanGesture(_:)))
    scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.new], context: &observerContext)
    scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.new], context: &observerContext)
    scrollView.scrollIndicatorInsets = UIEdgeInsets(top: configuration.normalStateHeight, left: 0, bottom: 0, right: 0)

    previousYOffset = scrollView.contentOffset.y
    scrollViewContentSizeChanged()
    scrollViewContentOffsetChanged()

    guard !firstScrollViewConfigured else {
      return
    }

    switch configuration.initialState {
    case .expanded:
      currentExpandedStateAvailability = true
      scrollView.topContentInset = configuration.expandedStateHeight!
      setContentOffsetY(-configuration.expandedStateHeight!, animated: false)
    case .normal:
      scrollView.topContentInset = configuration.normalStateHeight
      setContentOffsetY(-configuration.normalStateHeight, animated: false)
    case .compact:
      scrollView.topContentInset = configuration.normalStateHeight
      setContentOffsetY(-configuration.compactStateHeight!, animated: false)
    }

    firstScrollViewConfigured = true
  }

  private func removeObserving(scrollView: UIScrollView) {
    scrollView.panGestureRecognizer.removeTarget(self, action: #selector(handleScrollViewPanGesture(_:)))
    scrollView.removeObserver(self, forKeyPath: "contentSize", context: &observerContext)
    scrollView.removeObserver(self, forKeyPath: "contentOffset", context: &observerContext)
    previousYOffset = nil
  }

}*/
