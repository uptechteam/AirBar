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
  var normalView: UIView!
  var expandedView: UIView!
  var compactView: UIView!
  var airBarController: AirBarController!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self

    normalView = UIView()
    normalView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
    normalView.backgroundColor = UIColor.red

    expandedView = UIView()
    expandedView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
    expandedView.backgroundColor = UIColor.blue

    compactView = UIView()
    compactView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
    compactView.backgroundColor = UIColor.green

    airBar = UIView()
    airBar.addSubview(normalView)
    airBar.addSubview(compactView)
    airBar.addSubview(expandedView)
    airBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
    view.addSubview(airBar)

    let configuration = AirBarControllerConfiguration(normalStateHeight: 100, compactStateHeight: 60, expandedStateHeight: 240)
    airBarController = AirBarController(scrollView: tableView, configuration: configuration)
    airBarController.delegate = self
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
    let cell = UITableViewCell()

    cell.backgroundColor = UIColor(hue: CGFloat(indexPath.row) / 50, saturation: 0.5, brightness: 0.5, alpha: 1)

    return cell
  }
}

extension ViewController: AirBarControllerDelegate {
  func airBarController(_ controller: AirBarController, didChangeStateTo state: CGFloat) {
    let heightRange: (CGFloat, CGFloat) = state < 1 ? (60, 100) : (100, 240)

    normalView.alpha = state.map(from: (1, 2), to: (1, 0))
    compactView.alpha = state.map(from: (0, 1), to: (1, 0))
    expandedView.alpha = state.map(from: (1, 2), to: (0, 1))

    let stateRange: (CGFloat, CGFloat) = state < 1 ? (0, 1) : (1, 2)

    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: state.map(from: stateRange, to: heightRange))
    normalView.frame = frame
    compactView.frame = frame
    expandedView.frame = frame
    airBar.frame = frame
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
