//
//  LocationManager.swift
//  Magic Weather
//
//  Created by Jordan Pichler on 10/11/2017.
//  Copyright © 2017 Jordan A. Pichler. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherLocationDelegate {
	
}

class LocationManager: NSObject, CLLocationManagerDelegate {
	let locationManager = CLLocationManager()
	
	func requestLocationServiceAuthorization() {
		locationManager.delegate = self
		
		switch CLLocationManager.authorizationStatus() {
		case .notDetermined:
			// Request when-in-use authorization initially
			locationManager.requestWhenInUseAuthorization()
			break
			
		case .restricted, .denied:
			
			break
			// Disable location features
			
		case .authorizedWhenInUse, .authorizedAlways:
			// Enable location features
			break
		}
	}
	
	func startReceivingLocationChanges() {
		let authorizationStatus = CLLocationManager.authorizationStatus()
		if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
			// User has not authorized access to location information :(
			return
		}
		// Do not start services that aren't available.
		if !CLLocationManager.locationServicesEnabled() {
			// Location services is not available.
			return
		}
		// Configure and start the service.
		locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
		locationManager.distanceFilter = 1000 // In meters.
		locationManager.delegate = self
		locationManager.startUpdatingLocation()
	}
	
}
