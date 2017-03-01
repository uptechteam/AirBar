//
//  MenuView.swift
//  AirBar
//
//  Created by Evgeny Matviyenko on 2/25/17.
//  Copyright © 2017 uptechteam. All rights reserved.
//

import UIKit

class MenuView: UIView {
  @IBOutlet weak var stackView: UIStackView!

  func setStyle(light: Bool) {
    stackView.arrangedSubviews
      .flatMap { $0 as? UILabel }
      .forEach { $0.textColor = light ? UIColor.white : UIColor.black }
  }
}

