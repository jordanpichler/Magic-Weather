//
//  ForeCast.swift
//  Magic Weather
//
//  Created by Jordan Pichler on 22/05/2017.
//  Copyright © 2017 Jordan A. Pichler. All rights reserved.
//

import UIKit
import ForecastIO

struct Forecast {
    let summary: String
    let temperature: Float
    let humidity: Float
    let windspeed: Float
    let winddirection: Float?
    let tempLow: Float?
    let tempHigh: Float?
    let identifier: Icon?
    let timestamp: Date
    
    
    init(summary: String, temperature: Float, humidity: Float, windspeed: Float, winddirection: Float?, tempLow: Float?, tempHigh: Float?, identifier: Icon?, timestamp: Date) {
        self.summary = summary
        self.temperature = temperature
        self.humidity = humidity
        self.windspeed = windspeed
        self.winddirection = winddirection
        self.identifier = identifier
        self.timestamp = timestamp
        
        if let lo = tempLow {
            self.tempLow = lo
        } else {
            self.tempLow = 0
        }
        
        if let hi = tempHigh {
            self.tempHigh = hi
        } else {
            self.tempHigh = 0
        }
        
    }
}
