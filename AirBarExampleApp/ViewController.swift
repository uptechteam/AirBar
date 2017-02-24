//
//  ViewController.swift
//  AirBarExampleApp
//
//  Created by Evgeny Matviyenko on 2/24/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import AirBar
import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  var airBar: UIView!
  var backgroundView: UIView!
  var normalView: NormalView!
  var expandedView: UIView!
  var backButton: UIButton!
  var airBarController: AirBarController!

  var shouldHideStatusBar = false {
    didSet {
      guard shouldHideStatusBar != oldValue else { return }
      updateStatusBar()
    }
  }

  var prefersStatusBarStyle = UIStatusBarStyle.lightContent {
    didSet {
      guard prefersStatusBarStyle != oldValue else { return }
      updateStatusBar()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self

    backgroundView = UIImageView(image: #imageLiteral(resourceName: "grad"))

    normalView = UINib(nibName: "NormalView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! NormalView
    normalView.clipsToBounds = true

    expandedView = UINib(nibName: "ExpandedView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UIView
    expandedView.clipsToBounds = true

    backButton = UIButton(frame: CGRect(x: 22, y: 34, width: 40, height: 40))
    backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
    backButton.imageEdgeInsets = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)

    airBar = UIView()
    airBar.backgroundColor = UIColor.white
    airBar.layer.masksToBounds = false
    airBar.layer.shadowRadius = 4
    airBar.layer.shadowOpacity = 0.35
    airBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)

    airBar.addSubview(backgroundView)
    airBar.addSubview(normalView)
    airBar.addSubview(expandedView)
    airBar.addSubview(backButton)
    view.addSubview(airBar)

    let configuration = AirBarControllerConfiguration(normalStateHeight: 100, compactStateHeight: 24, expandedStateHeight: 244)
    airBarController = AirBarController(scrollView: tableView, configuration: configuration)
    airBarController.delegate = self
  }

  override var prefersStatusBarHidden: Bool {
    return shouldHideStatusBar
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return prefersStatusBarStyle
  }

  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return .fade
  }

  func updateStatusBar() {
    UIView.animate(withDuration: 0.20, delay: 0, options: .curveEaseInOut, animations: {
      self.setNeedsStatusBarAppearanceUpdate()
    }, completion: nil)
  }
}

extension ViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 50
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
  }
}

extension ViewController: AirBarControllerDelegate {
  func airBarController(_ controller: AirBarController, didChangeStateTo state: CGFloat) {
    let heightRange: (CGFloat, CGFloat) = state < 1 ? (24, 100) : (100, 244)

    shouldHideStatusBar = state > 0.05 && state < 0.95
    prefersStatusBarStyle = state > 0.5 ? .lightContent : .default

    backgroundView.alpha = state.map(from: (0, 1), to: (0, 1))

    let stateRange: (CGFloat, CGFloat) = state < 1 ? (0, 1) : (1, 2)

    let height = state.map(from: stateRange, to: heightRange)
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
    backgroundView.frame = frame
    airBar.frame = frame

    let normalViewY: CGFloat
    let normalViewAlpha: CGFloat
    let expandedViewY: CGFloat
    let expandedViewAlpha: CGFloat
    let backButtonAlpha: CGFloat

    if state < 1 {
      normalViewY = state.map(from: (0, 1), to: (-40, 40))
      normalViewAlpha = state
      expandedViewY = 40
      expandedViewAlpha = 0
      backButtonAlpha = 0
    } else {
      normalViewY = state.map(from: (1, 2), to: (40, 80))
      normalViewAlpha = state.map(from: (1, 2), to: (1, 0))
      expandedViewY = state.map(from: (1, 2), to: (40, 80))
      expandedViewAlpha = state.map(from: (1, 2), to: (0, 1))
      backButtonAlpha = state.map(from: (1.5, 2), to: (0, 1))
    }

    normalView.frame = CGRect(x: 0, y: normalViewY, width: view.frame.width, height: height - normalViewY)
    normalView.alpha = normalViewAlpha
    expandedView.frame = CGRect(x: 0, y: expandedViewY, width: view.frame.width, height: height - expandedViewY)
    expandedView.alpha = expandedViewAlpha
    backButton.alpha = backButtonAlpha
  }
}

// MARK: - CGFloat+Helpers

private extension CGFloat {
  func map(from firstBounds: (CGFloat, CGFloat), to secondBounds: (CGFloat, CGFloat)) -> CGFloat {
    guard self > firstBounds.0 else {
      return secondBounds.0
    }

    guard self < firstBounds.1 else {
      return secondBounds.1
    }

    let firstBoundsDelta = firstBounds.1 - firstBounds.0
    let ratio = (self - firstBounds.0) / firstBoundsDelta
    return secondBounds.0 + ratio * (secondBounds.1 - secondBounds.0)
  }

  func bounded(by bounds: (CGFloat, CGFloat)) -> CGFloat {
    return Swift.max(bounds.0, Swift.min(bounds.1, self))
  }
  
}
