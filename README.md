![AirBar](/Logo/Logo.png)
![pod](https://img.shields.io/cocoapods/v/AirBar.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Demo
![AirBar Demo](/Logo/Demo.gif)

## Description

AirBar is a library for creating `UIScrollView` driven expandable menus.
To make library is flexible as possible there is no UI elements provided inside. You need to implement all UIKit transformations by yourself.

## How to use

1) Create AirBarControllerConfiguration object.

2) Create AirBarController object with UIScrollView object and AirBarControllerConfiguration object.

3) Conform your UIViewController subclass with AirBarControllerDelegate protocol.

4) Set your view controller object to `delegate` property of AirBarController.

5) Provide view transformations in following method:
```swift
func airBarController(_ controller: AirBarController, didChangeStateTo state: CGFloat, withHeight height: CGFloat)
```

Also you can use AirBarExample application provided in repo.
