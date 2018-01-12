//
//  WeatherServiceManager.swift
//  Magic Weather
//
//
//  Created by Jordan Pichler on 15/05/2017.
//  Copyright © 2017 Jordan A. Pichler. All rights reserved.
//

import UIKit
import SwiftyJSON
import ForecastIO
import CoreLocation
import Alamofire

class WeatherServiceManager: NSObject {
    let APIKey = "4c933d66c2e42e70a510aebcb45b2e6b"
    var lat = 48.368170
    var lon = 14.513030

    func downloadWeatherData(for city: String, completion: @escaping (_ weatherData: [Forecast]) -> Void) {
        let client = DarkSkyClient(apiKey: APIKey)
        client.units = .si
        
        print("Fetching weather data for \(city)")
        
        // Convert City String to Lat/Lon coordinates
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(city) { (placemarks, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    print("City not found 🤷🏻‍♂️")
                    return
            }
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            print("Lat: \(self.lat), Lon: \(self.lon)")

            // Download weather data
            client.getForecast(latitude: self.lat, longitude: self.lon) { result in
                switch result {
                    
                case .success(let currentForecast, _):
                    print("Got data!")
                    
                    var foreCastArray = [Forecast]()
                    
                    // Fetch current conditions
                    let currentData = currentForecast.currently!
                    let forecastData = Forecast(summary: currentData.summary!, temperature: currentData.temperature!, humidity: currentData.humidity!, windspeed: currentData.windSpeed!, winddirection: currentData.windBearing, tempLow: currentForecast.daily?.data.first?.temperatureMin, tempHigh: currentForecast.daily?.data.first?.temperatureMax, identifier: currentData.icon, timestamp: currentData.time)
                    
                    // First index in array is curret data
                    foreCastArray.append(forecastData)
                    
                    // Fetch 5-day Forecast
                    for day in 1...5 {
                        if let daily = currentForecast.daily?.data[day] {
                            let dailyData = Forecast(summary: daily.summary!, temperature: 999, humidity: daily.humidity!, windspeed: daily.windSpeed!, winddirection: daily.windBearing, tempLow: daily.temperatureMin, tempHigh: daily.temperatureMax, identifier: daily.icon, timestamp: daily.time)
                            
                            foreCastArray.append(dailyData)
                        }
                    }
                    // Following 5 indices are the following 5 day forecasts
                    completion(foreCastArray)
                    
                    
                    
                case .failure(let error):
                    print("uh oh we got an error: \(error.localizedDescription)")
                    
                }
            }
            
        }
        
        
        
    
       
    }
}
