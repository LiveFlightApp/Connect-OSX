# LiveFlight Connect - OS X
LiveFlight Connect for OS X allows you to control Infinite Flight on an iOS or Android device via your Mac using either joystick, keyboard, or mouse. 

Uses Infinite Flight Connect, a TCP-based API introduced in version 15.10.0.

![](https://cdn.discourse.org/business/uploads/infinite_flight/original/3X/b/d/bdf296e94c96f375902144d48ff9db67fec376e9.png "LiveFlight Connect for OS X")

Usage
------------
  * Install the latest version at <a href="http://connect.liveflightapp.com">connect.liveflightapp.com</a>.
  * Enable Infinite Flight Connect within Infinite Flight, and make sure your device is on the same wifi network as your Mac.
  * Get your joystick set up as per in-app instructions.
  * Go have fun :)


Modifying Source
------------
LiveFlight Connect is built in Objective-C/Swift. Objective-C is used for referencing lower-level APIs (IOHIDLib, NSStream for TCP connection, etc.) and Swift is used for manipulating the UI and handling joystick/keyboard events. 

Clone the repo to start with. Connect-OSX uses submodules for third party libs. Run:

    git submodule init
    git submodule update

Open the project in Xcode and build it - you should be good to go! 

Compatible Devices
------------
There's no guarantee this will play perfectly with your joystick or configuration. Devices which require two USB ports need some work still. These joysticks work fine:
  * Thrustmaster T-Flight Hotas X
  * Saitek X52 Pro
  * Logitech Extreme 3D
  * Saitek Yoke and Throttle Quadrant

Licenses
-----------
This project uses:
 * https://github.com/robbiehanson/CocoaAsyncSocket
 * https://github.com/daltoniam/SwiftHTTP
 * https://github.com/ashleymills/Reachability.swift
 
 
LiveFlight Connect License
-----------
Licensed under the GPL-V3 License <a href="https://github.com/LiveFlightApp/Connect-OSX/blob/master/LICENSE">available here</a>.
