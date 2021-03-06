#ReactiveWeather [![Build Status](https://travis-ci.org/TCLee/ReactiveWeather.svg?branch=master)](https://travis-ci.org/TCLee/ReactiveWeather)

![Screenshot](http://tclee.github.io/ReactiveWeather/images/current-condition.png)` `
![Screenshot](http://tclee.github.io/ReactiveWeather/images/hourly-forecasts.png)` `
![Screenshot](http://tclee.github.io/ReactiveWeather/images/daily-forecasts.png)

ReactiveWeather is a sample iOS project to demonstrate the awesomeness of Functional Reactive Programming (FRP) using ReactiveCocoa (RAC).

This app was originally based on the tutorial at http://www.raywenderlich.com/55384 but I've decided to take it much further. This sample project adds additional features such as:

- Pull-to-Refresh to fetch the latest weather data.
- Classes are organize according to the Model-View-ViewModel (MVVM) design pattern. (e.g. UI code will only be in the View layer, instead of being all over the place etc...)
- ReactiveCocoa is used more extensively to demonstrate FRP style of programming.
- Unit tests written using BDD (Behavior-Driven Development) style. Examples of how to test ReactiveCocoa code.
- The sample code is well documented.

##Functional Reactive Programming (FRP)
Since [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) is based on Microsoft .NET's Reactive Extensions, you can learn more
about it at:

- [MSDN - Beginner's Guide to the Reactive Extensions](http://msdn.microsoft.com/en-us/data/gg577611)
- [Intro to Microsoft Rx](http://www.introtorx.com)

##Model-View-ViewModel (MVVM)
![MVVM](http://tclee.github.io/ReactiveWeather/images/mvvm-pattern.png)

ReactiveWeather classes are organized according to the MVVM design pattern. The **View** owns the **View Model** which in turn owns the **Model**. However, there is no dependency in the reverse direction (i.e. **View Model** does not know about the **View** that owns it).

See also: https://github.com/ReactiveCocoa/ReactiveViewModel

##Requirements

Before you work up a sweat and try to build the project, make sure you meet the system requirements below:

###Build Requirements
XCode 5 and iOS 7.0 SDK or later

###Runtime Requirements
iOS 7 or later

##Build and Run
The required frameworks are already included in the [Pods](Pods) directory.

If you want to fetch the latest version of all the frameworks, just run from the command line:

```
$ pod install
```

If you don't care about all that, just open `ReactiveWeather.xcworkspace`. Build and run. Done!

##Unit Tests
ReactiveWeather includes a suite of unit tests in the [ReactiveWeatherTests](ReactiveWeatherTests) directory. It demonstrates how you can test code written using the ReactiveCocoa framework.

Just build and run the tests in Xcode. Simple.

##Instruments
Included in the [Instruments](Instruments) directory are `*.trace` files that profile the performance impact of using ReactiveCocoa in this project.

Just double-click to open in Instruments to view the trace data.

##Frameworks
The list of frameworks used to build this app:

- [Mantle](https://github.com/Mantle/Mantle) - A lightweight model framework.
- [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) (RAC) - Functional Reactive Programming (FRP) in Cocoa and Cocoa Touch.
- [ReactiveViewModel](https://github.com/ReactiveCocoa/ReactiveViewModel) - RAC library for implementing Model-View-ViewModel (MVVM).

- **Unit Test Frameworks**
  * [Specta](https://github.com/specta/specta) - A light-weight BDD framework for Objective-C.
  * [Expecta](https://github.com/specta/expecta) - A simple Matcher framework that integrates perfectly with Specta.
  
##License
This project is released under the MIT license. Read the [LICENSE.md](https://github.com/tclee/ReactiveWeather/blob/master/LICENSE.md) file for more info.
