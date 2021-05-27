//------------------------------------------------------------------------------
//
// Communication.swift4a
// Swift For Arduino
//
// Created by Martijn Bogaert on 13/05/2021.
// Copyright © 2021 Martijn Bogaert. All rights reserved.
//
// NOTE: Modifications to the "Libraries:" comment line below will affect the build.
// Libraries:
//------------------------------------------------------------------------------

import AVR

// PIN SETUP
let potentiometerPin: Pin = A0
let ledStripPin: Pin = 12
pinMode(pin: potentiometerPin, mode: INPUT)
pinMode(pin: ledStripPin, mode: OUTPUT)

// LED STRIP SETUP
let amountOfLeds: UInt16 = 60
iLEDFastSetup(pin: ledStripPin, pixelCount: amountOfLeds, hasWhite: false, grbOrdered: true)

// VARIABLES SETUP
var currentColorLeds: iLEDFastColor = iLEDOff
var currentMassWeight: UInt16 = 0

// SERIAL SETUP
SetupSerial()
delay(milliseconds: 250) // Time for serial port to stabilize
sendMassWeightToSerial(currentMassWeight) // Already write start value to serial

// LOOP
while true {
    analogReadAsync(pin: potentiometerPin) { value in
        changeLedStripColorDependingOn(massWeight: value)
        
        if value != currentMassWeight { // Only write to serial when necessary
            sendMassWeightToSerial(value)
            currentMassWeight = value
        }
    }

    delay(milliseconds: 1000)
}

// FUNCTIONS
func changeLedStripColorDependingOn(massWeight value: UInt16) {
    let colorToDisplay: iLEDFastColor
    if value > 700 {
        colorToDisplay = iLEDRed
    } else if value > 400 {
        colorToDisplay = iLEDFastMakeColor(red: 255, green: 165, blue: 0, white: 0)
    } else {
        colorToDisplay = iLEDOff
    }
        
    if colorToDisplay != currentColorLeds { // Only change color when necessary
        for _ in 1...amountOfLeds {
            iLEDFastWritePixel(color: colorToDisplay)
        }
        delay(microseconds: 6) // Time for LEDs to change color
        currentColorLeds = colorToDisplay
    }
}

func sendMassWeightToSerial(_ value: UInt16) {
    print(staticString: "[", addNewline: false)
    print(value, addNewline: false)
    print("]")
}