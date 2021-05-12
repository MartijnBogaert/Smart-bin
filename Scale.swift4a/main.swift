//------------------------------------------------------------------------------
//
// test.swift4a
// Swift For Arduino
//
// Created by Martijn Bogaert on 11/05/2021.
// Copyright © 2021 Martijn Bogaert. All rights reserved.
//
// NOTE: Modifications to the "Libraries:" comment line below will affect the build.
// Libraries:
//------------------------------------------------------------------------------

import AVR

let calVal_eepromAddress: UInt16 = 0

SetupSerial()

print("")
print("Starting...")

if setupLoadCell() {
    print("Startup is complete")
} else {
    print("Timeout, check MCU>HX711 wiring and pin designations")
    while true {}
}

calibrate() //start calibration procedure

while true {
    var newDataReady = false

    // check for new data/start next conversion:
    if updateLoadCell() != 0 {
        newDataReady = true
    }

    // get smoothed value from the dataset:
    if newDataReady {
        let i: Float = getDataLoadCell()
        print(staticString: "Load_cell output val: ", addNewline: false)
        print(i)
        newDataReady = false
        delay(milliseconds: 100)
    }

    // receive command from serial terminal
    if available() {
        let inByte = read()
        print("")
        if inByte == 0x74 { //'t'
            tareNoDelayLoadCell() //tare
        } else if inByte == 0x72 { //'r'
            calibrate() //calibrate
        } else if inByte == 0x63 { //'c'
            changeSavedCalFactor() //edit calibration value manually
        }
    }

    // check if last tare operation is complete
    if getTareStatusLoadCell() {
        print("Tare complete")
    }
}

func calibrate() {
    print("***")
    print("Start calibration:")
    print("Place the load cell an a level stable surface.")
    print("Remove any load applied to the load cell.")
    print("Send t from serial monitor to set the tare offset.")

    var _resume = false
    while !_resume {
        updateLoadCell()
        if available() {
            let inByte = read()
            print("")
            if inByte == 0x74 { //'t'
                tareNoDelayLoadCell()
            }
        }
        if getTareStatusLoadCell() {
            print("Tare complete")
            _resume = true
        }
    }

    print("***")
    print("Now, place your known mass on the loadcell.")
    print("Then send the weight of this mass (i.e. 1000.00) from serial monitor. Send the digits one by one: first the thousand, then the hundred, then the ten, then the unit, then the tenth, then the hundredth.")

    let known_mass: Float = getMultiDigitFloatFromSerial()

    print("Known mass is")
    print(known_mass)

    refreshDataSetLoadCell() //refresh the dataset to be sure that the known mass is measured correct
    let newCalibrationValue: Float = getNewCalibrationLoadCell(known_mass) //get the new calibration value

    print(staticString: "New calibration value has been set to: ", addNewline: false)
    print(newCalibrationValue, addNewline: false)
    print(", use this as calibration value (calFactor) in your project sketch.")

    saveValueInEEPROM(newCalibrationValue)

    print("End calibration")
    print("***")
    print("To re-calibrate, send r from serial monitor.")
    print("For manual edit of the calibration value, send c from serial monitor.")
    print("***")
}

func changeSavedCalFactor() {
    let oldCalibrationValue: Float = getCalFactorLoadCell()
    
    print("***")
    print(staticString: "Current value is: ", addNewline: false)
    print(oldCalibrationValue)
    print("Now, send the new value from serial monitor, i.e. 696.0")

    let newCalibrationValue: Float = getMultiDigitFloatFromSerial()
    
    print(staticString: "New calibration value is: ", addNewline: false)
    print(newCalibrationValue)
    setCalFactorLoadCell(newCalibrationValue)
    
    saveValueInEEPROM(newCalibrationValue)
    
    print("End change calibration value")
    print("***")
}

func getMultiDigitFloatFromSerial() -> Float {
    var amount: Int = 6
    var numbers = [Float](repeating: 0.0, count: &amount)
    var power: Int8 = 3

    for i in 0..<numbers.count {
        print(staticString: "Digit ", addNewline: false)
        print(i + 1, addNewline: false)
        print(staticString: ": ", addNewline: false)
        var _resume = false
        while !_resume {
            if available() {
                updateLoadCell()
                let char = read()
                print("")
                if char >= 48 && char <= 57 {
                    numbers[i] = Float(char - 48) * powerOfTen(power)
                    power = power - 1
                    _resume = true
                }
            }
        }
    }

    var result: Float = 0.0
    for i in numbers {
        result += i
    }

    numbers.deallocate()
    return result
}

// Doesn't work since S4A can only write UInt8 types to EEPROM
func saveValueInEEPROM(_ value: Float) {
    print(staticString: "Save this value to EEPROM address ", addNewline: false)
    print(calVal_eepromAddress, addNewline: false)
    print("? y/n")

    var _resume = false
    while !_resume {
        if available() {
            let inByte = read()
            print("")
            if inByte == 0x79 { //'y'
                writeEEPROM(address: calVal_eepromAddress, value: UInt8(value))

                print(staticString: "Value ", addNewline: false)
                print(value, addNewline: false)
                print(staticString: " saved to EEPROM address ", addNewline: false)
                print(calVal_eepromAddress)
                _resume = true
            } else if inByte == 0x6E { //'n'
                print("Value not saved to EEPROM")
                _resume = true
            }
        }
    }
}

func powerOfTen(_ power: Int8) -> Float {
    var result: Float = 1
    if power > 0 {
        for _ in 0..<power {
            result *= 10.0
        }
        return result
    }
    if power < 0 {
        for _ in power..<0 {
            result /= 10.0
        }
    }
    return result
}
