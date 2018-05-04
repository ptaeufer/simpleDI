# simpleDI
a simple library for dependency injection in Swift

## Installation

To integrate simpleDI into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'simpleDI'
end
```

Then, run the following command:

```bash
$ pod install
```

## Preparation

To get started add a file called `Injector.swift` anywhere in your project.

## Usage

You can now define different modules in your project which have to extend `DependencyModule` :

```swift
class AppModule : DependencyModule {
  
  // Singleton
  let o1 = Object1()
  
  // New instance
  func o2() -> Object2() {
    return Object2()
  }
  
  // usage of other dependencies
  let o3 = Object3(o2 : inject())
}
```

If you want to inject a dependency in one of your classes : 


```swift
class ViewController : UIViewController {
  
  private let o1 : Object1 = inject()
  // or
  private let o1 = inject(Object1.self)
  
  ...
}
```
