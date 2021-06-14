# Smart bin
## Swift for Arduino code for Arduino side of IoT project

#### Important!
The projects in this repo have been developed using version 4.4 of Swift for Arduino. If you're using version 4.5 the scale project will fail to build. To get swift.main working again, change this line

```swift
writeEEPROM(address: calVal_eepromAddress, value: UInt8(value))
```

into this line

```swift
writeEEPROM(address: calVal_eepromAddress, value: UInt8(safe: value) ?? 0)
```

Unfortunately, due to the C and C++ files, the project still fails to build. We're working on fixing the problem.
