//
//  WeatherViewController.swift
//  Magic Weather
//
//  Created by Jordan Pichler on 15/05/2017.
//  Copyright © 2017 Jordan A. Pichler. All rights reserved.
//

import UIKit
import Lottie
import ForecastIO
import Dance
import Cartography

class WeatherViewController: UIViewController {

	// MARK: - Outlets, Properties -
	
    let weatherManager = WeatherServiceManager()

    @IBOutlet weak var LowHighTemps: UIStackView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var tempLowLabel: UILabel!
    @IBOutlet weak var tempHighLabel: UILabel!
    @IBOutlet weak var dayForecastView: UIScrollView!
    @IBOutlet weak var weatherAnimationView: UIView!

    @IBAction func snowbutton() { displaySnow() }
    @IBAction func sunbutton() { displaySun() }
    @IBAction func rainbutton() { displayRain() }
    @IBAction func rainUivButton() { displayRainUiView() }
    @IBAction func rainCaButton() { displayRainCoreAnimation() }
    @IBAction func cloudybutton() { displayCloudy() }
    @IBAction func windbutton() { displayWind() }
    @IBAction func clear() { clearAnimationView() }
    
    @IBOutlet var labelForDay: [UILabel]!

    @IBOutlet var iconForDay: [UIImageView]!
	
	private var layerCount = 0
    private var neededLayers = 1
    // Make enum!
    let icons: Dictionary<String, UIImage> = ["clear-day": #imageLiteral(resourceName: "Sun"),
											  "clear-night": #imageLiteral(resourceName: "Sun"),
											  "rain": #imageLiteral(resourceName: "droplets"), "snow": #imageLiteral(resourceName: "snowflake-2"),
											  "cloudy": #imageLiteral(resourceName: "Cloudy"),
											  "fog": #imageLiteral(resourceName: "Cloud"),
											  "partly-cloudy-day": #imageLiteral(resourceName: "PartlyCloudy"),
											  "partly-cloudy-night": #imageLiteral(resourceName: "PartlyCloudy"),
											  "wind": #imageLiteral(resourceName: "Cloud"),
											  "sleet": #imageLiteral(resourceName: "droplets"),]
	
	// MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Prepare labels for animation
        summaryLabel.transform = CGAffineTransform(translationX: 30, y: 0)
        temperatureLabel.transform = CGAffineTransform(translationX: 30, y: 0)
        LowHighTemps.transform = CGAffineTransform(translationX: 30, y: 0)
        dayForecastView.transform = CGAffineTransform(translationX: 30, y: 0)

        summaryLabel.alpha = 0
        temperatureLabel.alpha = 0
        LowHighTemps.alpha = 0
        dayForecastView.alpha = 0
        
        dayForecastView.contentSize.width = 580
		weatherAnimationView.contentMode = .scaleAspectFit
    }

    @IBAction func onButtonClick(_ sender: Any) {

        let searchCity = "Innsbruck"
        weatherManager.downloadWeatherData(for: searchCity) { (result: [Forecast]) in
            DispatchQueue.main.async {
                if let today = result.first {
                self.cityLabel.text = searchCity
                self.temperatureLabel.text = "\(Int(today.temperature.rounded()))°"
                self.summaryLabel.text = today.summary

                self.tempLowLabel.text = "Lo \(Int(today.tempLow!.rounded()))°"
                self.tempHighLabel.text = "Hi \(Int(today.tempHigh!.rounded()))°"
                    
                }
                // Clear Animation View of prior weather animations
                self.clearAnimationView()
				self.weatherAnimationView.alpha = 0
				
                // Set up new weather animation
                if let weatherCode = result.first?.identifier {
					switch weatherCode {
					case .clearDay, .clearNight:
						print("Sunny")
						self.displaySun()

					case .rain, .sleet:
						print("Rain")
						self.displayRain()

					case .wind:
						print("Wind")
						self.displayWind()

					case .snow:
						print("Snow")
						self.displaySnow()

					case .fog, .cloudy, .partlyCloudyDay, .partlyCloudyNight:
						print("Cloudy")
						self.displayCloudy()
					}
                }

				self.updateDailyForecastWith(data: result)
                    
				// Fade in Weather Animation
				UIView.animate(withDuration: 2, animations: {
					self.weatherAnimationView.alpha = 1
					}, completion: nil)

				// Slide & Fade in Labels and Forecast
				UIView.animate(withDuration: 3, delay: 0.1, usingSpringWithDamping: 0.1, initialSpringVelocity: -10, animations: {
					self.temperatureLabel.alpha = 1
					self.temperatureLabel.transform = CGAffineTransform(translationX: 0, y: 0)
					}, completion: nil)

				UIView.animate(withDuration: 1, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [], animations: {
					self.LowHighTemps.alpha = 1
					self.LowHighTemps.transform = CGAffineTransform(translationX: 0, y: 0)
					}, completion: nil)

				UIView.animate(withDuration: 1, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [], animations: {
					self.summaryLabel.alpha = 1
					self.summaryLabel.transform = CGAffineTransform(translationX: 0, y: 0)
					}, completion: nil)

				UIView.animate(withDuration: 1, delay: 0.4, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [], animations: {
					self.dayForecastView.alpha = 1
					self.dayForecastView.transform = CGAffineTransform(translationX: 0, y: 0)
					}, completion: nil)
                }
            }
        }

	// MARK: - Helper methods -
	
    private func updateDailyForecastWith(data: [Forecast]) {
        let f = DateFormatter()
        for i in 1...5 {
            let weekdayno = Calendar.current.component(.weekday, from: data[i].timestamp)
            let weekday = f.shortWeekdaySymbols[weekdayno-1] // Calendar Component = 1-7, weekdaysymbols = 0-6
            let temp = Int(data[i].tempHigh!.rounded())
            labelForDay[i-1].text = "\(weekday)\n\(temp)°"
            iconForDay[i-1].image = icons[data[i].identifier!.rawValue]
        }
    }
	
	@IBAction func didSelectLayerAmount(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			neededLayers = 1
		case 1:
			neededLayers = 20
		case 2:
			neededLayers = 150
		default:
			break
		}
		print("Changed needLayers to \(neededLayers)")
		
	}

    private func clearAnimationView() {
        // Stop UIKit Animations (Sun)
        weatherAnimationView.layer.removeAllAnimations()
        weatherAnimationView.transform = CGAffineTransform(rotationAngle: 0)
		
		// Reset alpha
		weatherAnimationView.alpha = 1
		
        // Remove Subviews (Lottie)
        print("removing subView")
        for view in weatherAnimationView.subviews {
            view.removeFromSuperview()
        }
        
        // Remove Sublayers (Clouds/Snow)
        weatherAnimationView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
		
		layerCount = 0
    }
	
	// MARK: - Animation Code -

    // -- Third Party, Dance (Core Animation)
    private func displayCloudy() {
		for _ in 1...self.neededLayers {
			let imageAnimationView = UIImageView(image: #imageLiteral(resourceName: "CloudyWhiteStroke"))
			imageAnimationView.contentMode = .scaleAspectFit

			let imageAnimationView2 = UIImageView(image: #imageLiteral(resourceName: "CloudyGrey"))
			imageAnimationView2.contentMode = .scaleAspectFit

			weatherAnimationView.addSubview(imageAnimationView2)
			weatherAnimationView.addSubview(imageAnimationView)
			
			weatherAnimationView.addConstraintsWithFormat(format: "H:[v0]|", views: imageAnimationView)
			weatherAnimationView.addConstraintsWithFormat(format: "H:|-[v0]", views: imageAnimationView2)
			weatherAnimationView.addConstraintsWithFormat(format: "V:[v0]-|", views: imageAnimationView)
			weatherAnimationView.addConstraintsWithFormat(format: "V:|-[v0]", views: imageAnimationView2)
			
			imageAnimationView.dance.animate(duration: 2, curve: .easeInOut) {
				$0.transform = CGAffineTransform(translationX: -110, y: 0)
				}.addCompletion { _ in
					print("cloud white moved")
				}.start(after: 0.5)

			imageAnimationView2.dance.animate(duration: 2, curve: .easeInOut) {
				$0.transform = CGAffineTransform(translationX: 90, y: 0)
				}.addCompletion { _ in
					print("cloud gray moved")
				}.start(after: 0.5)

			// (!) This Library doesn't have a loop option!?
			
			imageAnimationView.dance.animate(duration: 2, curve: .easeInOut) {
				$0.transform = CGAffineTransform(translationX: 0, y: 0)
				}.addCompletion { _ in
					print("cloud white moved back")
				}.start(after: 2.7)
			
			imageAnimationView2.dance.animate(duration: 2, curve: .easeInOut) {
				$0.transform = CGAffineTransform(translationX: 0, y: 0)
				}.addCompletion { _ in
					print("cloud gray moved back")
				}.start(after: 2.7)
		}
    }
    
    // -- Core Animation
    private func displaySnow() {
		for _ in 1...self.neededLayers {
			summaryLabel.textColor = .snow
		
			// Generate Cloud
			let cloudEmitter = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "cloud-particle-1"), #imageLiteral(resourceName: "cloud-particle-2")], type: .clouds)
			cloudEmitter.emitterPosition = CGPoint(x: (view.frame.width / 2), y: 50)
			cloudEmitter.emitterSize = CGSize(width: weatherAnimationView.frame.width / 2, height: 500)
		
			let cloudEmitter1 = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "cloud-particle-1"), #imageLiteral(resourceName: "cloud-particle-2")], type: .clouds, inversed: true)
			cloudEmitter1.emitterPosition = CGPoint(x: (view.frame.width / 2 - 40), y: 60)
			cloudEmitter1.emitterSize = CGSize(width: weatherAnimationView.frame.width / 2, height: 500)
		
			weatherAnimationView.layer.addSublayer(cloudEmitter)
			weatherAnimationView.layer.addSublayer(cloudEmitter1)
		
			// Generate Snowflakes
			let emitter = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "snowflake-1"), #imageLiteral(resourceName: "snowflake-2"), #imageLiteral(resourceName: "snowflake-3")], type: .snowflakes)
			emitter.emitterPosition = CGPoint(x: (view.frame.width / 2), y: 60)
			emitter.emitterSize = CGSize(width: weatherAnimationView.frame.width / 2, height: 2)
		
			weatherAnimationView.layer.addSublayer(emitter)
		}
	}
    
    // -- UIView Animations
    private func displaySun() {
		for _ in 1...self.neededLayers {
			summaryLabel.textColor = .sun
			
			let imageAnimationView = UIImageView(image: #imageLiteral(resourceName: "Sun"))
			weatherAnimationView.addSubview(imageAnimationView)
			imageAnimationView.contentMode = .scaleAspectFit
			weatherAnimationView.contentMode = .scaleAspectFit
			weatherAnimationView.addConstraintsWithFormat(format: "H:|[v0]|", views: imageAnimationView)
			weatherAnimationView.addConstraintsWithFormat(format: "V:|[v0]|", views: imageAnimationView)
			
	//		weatherAnimationView.alpha = 0
			let rotation = CGAffineTransform(rotationAngle: 130 * (.pi / 180))
			
			UIView.animate(withDuration: 5,
						   delay: 0,
						   usingSpringWithDamping: 0.5,
						   initialSpringVelocity: 1,
						   options: [.autoreverse, .repeat],
						   animations: {
	//						self.weatherAnimationView.alpha = 1
							self.weatherAnimationView.transform = rotation
			}) { Void in
				print("finished transform!")
			}
	//
	//		Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
	//			print("Timer fired! Alpha looks like it's at 50%")
	//			UIView.animate(withDuration: 5,
	//						   delay: 0,
	//						   options: [.beginFromCurrentState],
	//						   animations: {
	//							print("alpha: \(self.weatherAnimationView.alpha)")
	//							self.weatherAnimationView.alpha = 0
	//			}) { Void in
	//				print("finished alpha!")
	//			}
	//		}
		}
    }

    // -- Lottie
    private func displayWind() {
		for _ in 1...self.neededLayers {
			summaryLabel.textColor = .windy

			let lottieAnimationView = LOTAnimationView(name: "windturbine")
			lottieAnimationView.frame = weatherAnimationView.frame
			lottieAnimationView.center = CGPoint(x: weatherAnimationView.frame.size.width / 2,
												  y: weatherAnimationView.frame.size.height / 2)
			self.weatherAnimationView.addSubview(lottieAnimationView)
			lottieAnimationView.contentMode = UIViewContentMode.scaleAspectFit
			lottieAnimationView.loopAnimation = true
			lottieAnimationView.animationSpeed = 1.5
			lottieAnimationView.play()
			
			let lineEmitter = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "line-1")], type: .windlines)
			lineEmitter.emitterPosition = CGPoint(x: -200, y: weatherAnimationView.frame.minY)
			lineEmitter.emitterSize = CGSize(width: 300, height: 900)
			
			weatherAnimationView.layer.addSublayer(lineEmitter)
			
			let leafEmitter = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "leaf-1"), #imageLiteral(resourceName: "leaf-2")], type: .leaves)
			leafEmitter.emitterPosition = CGPoint(x: -200, y: weatherAnimationView.frame.minY)
			leafEmitter.emitterSize = CGSize(width: 300, height: 900)
			
			weatherAnimationView.layer.addSublayer(leafEmitter)
			print(weatherAnimationView.layer.sublayers!.count)
		}
	}
	
	// MARK: - Rain (for comparison) -
	// -- Lottie (Key Frames)
	private func displayRain() {
		for _ in 1...self.neededLayers {
			summaryLabel.textColor = .rain
			layerCount += 1
			print("Added Lottie Layer. Total count: \(layerCount)")
			
			let lottieAnimationView = LOTAnimationView(name: "rain")
			lottieAnimationView.loopAnimation = true
			lottieAnimationView.animationSpeed = 3
			lottieAnimationView.play()
			
			// Set constraints and appearance
			lottieAnimationView.contentMode = .scaleAspectFit
			self.weatherAnimationView.addSubview(lottieAnimationView)
			weatherAnimationView.addConstraintsWithFormat(format: "H:|[v0]|", views: lottieAnimationView)
			weatherAnimationView.addConstraintsWithFormat(format: "V:|[v0]|", views: lottieAnimationView)
			self.weatherAnimationView.contentMode = .scaleAspectFit
		}
	}
	
	// -- Rain with Core Animation
	private func displayRainCoreAnimation() {
		if let rainView = Bundle.main.loadNibNamed("RainCloudView", owner: self,options: nil)?.first as? RainCloud {
			for _ in 1...self.neededLayers {
				layerCount += 1
				print("Added CA Layer. Total count: \(layerCount)")

				// Add to View
				weatherAnimationView.addSubview(rainView)
				
				// Constrain to center
				constrain(rainView, weatherAnimationView) {rainView, weatherAnimationView in
					rainView.edges == weatherAnimationView.edges
				}
				
				// Important: calculate deltas before transforming!
				let deltaX = rainView.dropletsBottom.center.x - rainView.dropletsCenter.center.x
				let deltaY =  rainView.dropletsBottom.center.y - rainView.dropletsCenter.center.y
				
				// CABasicAnimation uses a single key frame and interpolates equally from
				// the `fromValue` to the `toValue` over the `duration`
				// alternatively, the `byValue` field can be defined to modify the existing properties
				let translation = CABasicAnimation(keyPath: #keyPath(CALayer.position))
				translation.duration = 0.5
				translation.byValue = [deltaX, deltaY]

	//				// ----
	//
	//				let mirror = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
	//				let matrix = CATransform3DMakeScale(1, -1, 1)
	//				mirror.duration = 2
	//				mirror.toValue = NSValue(caTransform3D: matrix)
	//
	//				// ----
				
				let fadeIn = CABasicAnimation(keyPath: "opacity")
				fadeIn.duration = 0.5
				fadeIn.fromValue = 0
				fadeIn.toValue = 1

				// Cloud pulsating
				let pulsate = CABasicAnimation(keyPath: "transform.scale")
				pulsate.duration = 0.5
				pulsate.byValue = 0.1 // Scale up 10%
				pulsate.autoreverses = true
				
				// CAKeyFrameAnimation allows to define custom keyframe intervals and values
				// The 'keyTime` is an array which contains the progress of the animation time! (0-1)
				// The 'values` is an array with the values of the animation,
				// they are assigned to the `keytimes` indices 1:1
				let fadeOut50 = CAKeyframeAnimation(keyPath: "opacity")
				fadeOut50.duration = 0.5
				fadeOut50.values = 	 [1, 0.5]
				fadeOut50.keyTimes = [0, 1]
				
				let fadeOut100 = CAKeyframeAnimation(keyPath: "opacity")
				fadeOut100.duration = 0.5
				fadeOut100.values = 	[0.5, 0]
				fadeOut100.keyTimes = 	[0, 1]

				let fadeOut = CABasicAnimation(keyPath: "opacity")
				fadeOut.duration = 0.5
				fadeOut.byValue = -0.5
				
				// Group animations for each droplet layer
				let moveDownAndFadeIn = CAAnimationGroup()
				moveDownAndFadeIn.animations = [translation, fadeIn]
				moveDownAndFadeIn.duration = 0.5
				moveDownAndFadeIn.isRemovedOnCompletion = false
				moveDownAndFadeIn.repeatCount = Float.infinity // and beyond!
				
				let moveDownAndFadeOut = CAAnimationGroup()
				moveDownAndFadeOut.animations = [translation, fadeOut]
				moveDownAndFadeOut.duration = 0.5
				moveDownAndFadeOut.isRemovedOnCompletion = false
				moveDownAndFadeOut.repeatCount = Float.infinity
				
				// Add group of animations to layer. Key is not required here
				rainView.dropletsTop.layer.add(moveDownAndFadeIn, forKey: nil)
				rainView.dropletsCenter.layer.add(moveDownAndFadeOut, forKey: nil)
				rainView.dropletsBottom.layer.add(moveDownAndFadeOut, forKey: nil)

				// Also possible to add individual animations to view's layers
				// Remember to set `isRemovedOnCompletion` to false and repeat count!
				fadeOut50.isRemovedOnCompletion = false
				fadeOut50.repeatCount = Float.infinity
				translation.isRemovedOnCompletion = false
				translation.repeatCount = Float.infinity
				pulsate.isRemovedOnCompletion = false
				pulsate.repeatCount = Float.infinity
				
				rainView.cloud.layer.add(pulsate, forKey: "transform")
			}
		}
	}
	
	// -- Rain with UIView.animate()
	private func displayRainUiView() {
		if let rainView = Bundle.main.loadNibNamed("RainCloudView", owner: self, options: nil)?.first as? RainCloud {
			for _ in 1...self.neededLayers {

				weatherAnimationView.addSubview(rainView)
				layerCount += 1
				print("Added UIView Layer. Total count: \(layerCount)")
				
				// Constrain to center
				constrain(rainView, weatherAnimationView) {rainView, weatherAnimationView in
					rainView.edges == weatherAnimationView.edges
				}
				
				UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: ({
					rainView.cloud.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
				}))
				
				UIView.animate(withDuration: 0.6, delay: 0, options: [.curveLinear ,.repeat], animations: ({
					// Important: calculate deltas before transforming!
					let deltaX = rainView.dropletsBottom.center.x - rainView.dropletsCenter.center.x
					let deltaY =  rainView.dropletsBottom.center.y - rainView.dropletsCenter.center.y
					
					rainView.dropletsTop.center = rainView.dropletsCenter.center
					rainView.dropletsTop.alpha = 1
					
					rainView.dropletsCenter.center = rainView.dropletsBottom.center
					rainView.dropletsCenter.alpha = 0.5
					
					rainView.dropletsBottom.transform = CGAffineTransform(translationX: deltaX, y: deltaY)
					rainView.dropletsBottom.alpha = 0
				}))
			}
		}
	}
}
