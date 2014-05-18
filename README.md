#ReactiveWeather

ReactiveWeather is a sample project to demonstrate the awesomeness of Functional Reactive Programming (FRP) using Objective-C. 

##Requirements

Before you work up a sweat and try to build the project, make sure you meet the system requirements below:

###Build Requirements
XCode 5 and iOS 7.0 SDK or later

###Runtime Requirements
iOS 7 or later

##Build and Run
The required frameworks are already included in the [Pods](https://github.com/tclee/ReactiveWeather/Pods) sub-directory.

If you want to fetch the latest version of all the frameworks, just run from the command line:

  $ pod install

If you don't care about all that, just build and run in Xcode and you're good to go.

##Unit Tests
ReactiveWeather includes a suite of unit tests in the [ReactiveWeatherTests](https://github.com/tclee/ReactiveWeather/ReactiveWeatherTests) sub-directory. It demonstrates how you can test code written using the ReactiveCocoa framework.

Just build and run the tests in Xcode. Simple.

##Frameworks
- [Mantle](https://github.com/Mantle/Mantle) - A lightweight model framework.
- [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) (RAC) - Functional Reactive Programming (FRP) in Cocoa and Cocoa Touch.
- [ReactiveViewModel](https://github.com/ReactiveCocoa/ReactiveViewModel) - Model-View-ViewModel (MVVM) pattern using ReactiveCocoa. 

###Unit Test Frameworks
* [Specta](https://github.com/specta/specta) - A light-weight BDD framework for Objective-C.
* [Expecta](https://github.com/specta/expecta) - A simple Matcher framework that integrates perfectly with Specta.