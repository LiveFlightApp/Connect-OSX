# LiveFlight Connect - OS X
LiveFlight Connect for OS X allows you to control Infinite Flight on an iOS or Android device via your Mac using either joystick, keyboard, or mouse. 

Uses Infinite Flight Connect, a TCP-based API introduced in version 15.10.0.

## Deprecated

**As of 26th February 2020, LiveFlight Connect is no longer officially supported.**

The apps are still available for download and the source code is available, however, no official updates are planned, nor will support be provided for any issues.

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
  * Logitech Extreme 3D

Licenses
-----------
This project uses:
 * https://github.com/robbiehanson/CocoaAsyncSocket
 * https://github.com/daltoniam/SwiftHTTP
 * https://github.com/ashleymills/Reachability.swift
 
 
LiveFlight Connect License
-----------
Licensed under the GPL-V3 License <a href="https://github.com/LiveFlightApp/Connect-OSX/blob/master/LICENSE">available here</a>.
