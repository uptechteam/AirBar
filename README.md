<p align="center">
	<a href="https://github.com/uptechteam/AirBar/"><img src="Logo/Logo.png" alt="AirBar" width="600" height="120" /></a><br /><br />
  UIScrollView driven expandable menu. <br /><br />
  <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
</p>
<br />

## Description

AirBar is a library for creating cool expandable menus.
Library observes UIScrollView scroll and provides state you can apply to your UI elements.

## Demo
![AirBar Demo](/Logo/Demo.gif)

## Installation
Library supports [Carthage](https://github.com/Carthage/Carthage) dependency manager. To install AirBar add following line to Cartfile in the root folder of your project.
```
github "uptechteam/AirBar" ~> 2.0
```
## How to use

1) Create `BarController` object using `BarController(configuration Configuration, stateObserver: StateObserver)` initializer, where `Configuration` is struct that contains height config and `StateObserver` is closure that will be called on state change.

2) Bind `BarController` to your `UIScrollView` object using `set(scrollView: UIScrollView)` method. 

3) Provide UI transformations in closure passed as `StateObserver` init argument. Closure will receive `State` object that has following public methods:
- `height()` - returns bar height;
- `transitionProgress()` - returns bar transition progress between 0 and 2, where 0 - compact state, 1 - normal state, 2 - expanded state;
- `value(compactNormalRange: ValueRangeType, normalExpandedRange: ValueRangeType)` - returns transformed CGFloat value that can be used for configuring UIKit element properties. `ValueRangeType` is enum with `.range(CGFloat, CGFloat)` and `.value(CGFloat)` cases. You can use it for example if you need static value `1` in normal-expanded transition and range (0, 1) in compact-normal transition.

4) (Optional) Contribute to repository.

Also you can find example application in library project.

## Multiple UIScrollView objects
`BarController` supports using multiple `UIScrollView` objects. You can use `preconfigure(scrollView: UIScrollView)` method to configure scrolling view before setting it with `set(scrollView: UIScrollView)` method. 

## TODO
- Implement expansion/concatination resistance;
- ...
