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

    @IBAction func snowbutton(_ sender: Any) {
        self.displaySnow()
    }
    @IBAction func sunbutton(_ sender: Any) {
        self.displaySun()
    }
    
    @IBAction func rainbutton(_ sender: Any) {
        self.displayRain()
    }
   
    @IBAction func cloudybutton(_ sender: Any) {
        self.displayRainUiView()
    }
    @IBAction func windbutton(_ sender: Any) {
        self.displayRainCoreAnimation()
    }
    
    @IBAction func clear(_ sender: Any) {
        self.clearAnimationView()
    }
    
    @IBOutlet var labelForDay: [UILabel]!

    @IBOutlet var iconForDay: [UIImageView]!
    
    var lottieAnimationView: LOTAnimationView?
	
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
                    UIView.animate(withDuration: 3, animations: {
                        self.weatherAnimationView.alpha = 1
                    }, completion: nil)

                    // Slide & Fade in Labels and Forecast
                    UIView.animate(withDuration: 3, delay: 0.1, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
                        self.temperatureLabel.alpha = 1
                        self.temperatureLabel.transform = CGAffineTransform(translationX: 0, y: 0)
                    }, completion: nil)

                    UIView.animate(withDuration: 1, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [.curveLinear], animations: {
                        self.LowHighTemps.alpha = 1
                        self.LowHighTemps.transform = CGAffineTransform(translationX: 0, y: 0)
                    }, completion: nil)

                    UIView.animate(withDuration: 1, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
                        self.summaryLabel.alpha = 1
                        self.summaryLabel.transform = CGAffineTransform(translationX: 0, y: 0)
                    }, completion: nil)

                    UIView.animate(withDuration: 1, delay: 0.4, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [], animations: {
                        self.dayForecastView.alpha = 1
                        self.dayForecastView.transform = CGAffineTransform(translationX: 0, y: 0)
                    }, completion: nil)

                    print("Labels set!")
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
        let imageAnimationView = UIImageView(image: #imageLiteral(resourceName: "CloudyWhiteStroke"))
        imageAnimationView.frame.size = CGSize(width: weatherAnimationView.frame.width, height: 500)
        imageAnimationView.center = CGPoint(x: (view.frame.width / 2 - 20), y: 140)
        imageAnimationView.contentMode = .scaleAspectFit

        let imageAnimationView2 = UIImageView(image: #imageLiteral(resourceName: "CloudyGrey"))
        imageAnimationView2.frame.size = CGSize(width: weatherAnimationView.frame.width, height: 500)
        imageAnimationView2.center = CGPoint(x: (view.frame.width / 2 - 110), y: 90)
        imageAnimationView2.contentMode = .scaleAspectFit

        weatherAnimationView.addSubview(imageAnimationView2)
        weatherAnimationView.addSubview(imageAnimationView)
        
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
    
    // -- Core Animation
    private func displaySnow() {
        summaryLabel.textColor = .snow
        
        // Generate Cloud
        let cloudEmitter = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "cloud-particle-1"), #imageLiteral(resourceName: "cloud-particle-2")], type: .clouds)
        cloudEmitter.emitterPosition = CGPoint(x: (view.frame.width / 2 - 65), y: 50)
        cloudEmitter.emitterSize = CGSize(width: weatherAnimationView.frame.width / 2, height: 500)
        
        let cloudEmitter1 = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "cloud-particle-1"), #imageLiteral(resourceName: "cloud-particle-2")], type: .clouds, inversed: true)
        cloudEmitter1.emitterPosition = CGPoint(x: (view.frame.width / 2 - 80), y: 60)
        cloudEmitter1.emitterSize = CGSize(width: weatherAnimationView.frame.width / 2, height: 500)
        
        weatherAnimationView.layer.addSublayer(cloudEmitter)
        weatherAnimationView.layer.addSublayer(cloudEmitter1)
        
        let emitter = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "snowflake-1"), #imageLiteral(resourceName: "snowflake-2"), #imageLiteral(resourceName: "snowflake-3")], type: .snowflakes)
        
        
        emitter.emitterPosition = CGPoint(x: (view.frame.width / 2) - (weatherAnimationView.frame.width / 4), y: 60)
        emitter.emitterSize = CGSize(width: weatherAnimationView.frame.width / 2, height: 2)
        weatherAnimationView.layer.addSublayer(emitter)
    }
    
    // -- UIView Animations
    private func displaySun() {
        summaryLabel.textColor = .sun
        
        let imageAnimationView = UIImageView(image: #imageLiteral(resourceName: "Sun"))
        imageAnimationView.frame = weatherAnimationView.frame
        imageAnimationView.center = CGPoint(x: weatherAnimationView.frame.size.width / 2,
											y: weatherAnimationView.frame.size.height / 2)
        weatherAnimationView.addSubview(imageAnimationView)
		imageAnimationView.contentMode = .scaleAspectFit
		weatherAnimationView.contentMode = .scaleAspectFit
		
		weatherAnimationView.alpha = 0
		let rotation = CGAffineTransform(rotationAngle: 130 * (.pi / 180))
		
        UIView.animate(withDuration: 10,
                       delay: 0,
                       options: [.curveEaseIn],
                       animations: {
						self.weatherAnimationView.alpha = 1
                        self.weatherAnimationView.transform = rotation
		}) { Void in
			print("finished transform!")
		}

		Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
			print("Timer fired! Alpha looks like it's at 50%")
			UIView.animate(withDuration: 5,
						   delay: 0,
						   options: [.beginFromCurrentState],
						   animations: {
							print("alpha: \(self.weatherAnimationView.alpha)")
							self.weatherAnimationView.alpha = 0
			}) { Void in
				print("finished alpha!")
			}
		}
		
    }

    // -- Lottie
    private func displayWind() {
        summaryLabel.textColor = .windy

        lottieAnimationView = LOTAnimationView(name: "windturbine")
        lottieAnimationView?.frame = weatherAnimationView.frame
        lottieAnimationView?.center = CGPoint(x: weatherAnimationView.frame.size.width / 2, y: weatherAnimationView.frame.size.height / 2)
        self.weatherAnimationView.addSubview(lottieAnimationView!)
        lottieAnimationView?.contentMode = UIViewContentMode.scaleAspectFit

        lottieAnimationView?.loopAnimation = true
        lottieAnimationView?.animationSpeed = 1.5

        lottieAnimationView?.play()
        
        let lineEmitter = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "line-1")], type: .windlines)
        lineEmitter.emitterPosition = CGPoint(x: -200, y: weatherAnimationView.frame.minY)
        lineEmitter.emitterSize = CGSize(width: 300, height: 900)
        
        weatherAnimationView.layer.addSublayer(lineEmitter)
        
        let leaveEmitter = WeatherEmitter.createEmitter(with: [#imageLiteral(resourceName: "leaf-1"), #imageLiteral(resourceName: "leaf-2")], type: .leaves)
        leaveEmitter.emitterPosition = CGPoint(x: -200, y: weatherAnimationView.frame.minY)
        leaveEmitter.emitterSize = CGSize(width: 300, height: 900)
        
        weatherAnimationView.layer.addSublayer(leaveEmitter)
    }
	
	// MARK: - Rain (for comparison) -
	// -- Lottie (Key Frames)
	private func displayRain() {
		for _ in 1...neededLayers {
			summaryLabel.textColor = .rain
			layerCount += 1
			print("Added Lottie Layer. Total count: \(layerCount)")
			lottieAnimationView = LOTAnimationView(name: "rain")
			lottieAnimationView?.contentMode = .scaleAspectFit
			self.weatherAnimationView.addSubview(lottieAnimationView!)
			weatherAnimationView.addConstraintsWithFormat(format: "H:|[v0]|", views: lottieAnimationView!)
			weatherAnimationView.addConstraintsWithFormat(format: "V:|[v0]|", views: lottieAnimationView!)
			
			self.weatherAnimationView.contentMode = .scaleAspectFit
			
			lottieAnimationView?.loopAnimation = true
			lottieAnimationView?.animationSpeed = 3
			lottieAnimationView?.play()
		}
	}
	
	// -- Rain with Core Animation
	private func displayRainCoreAnimation() {
            if let rainView = Bundle.main.loadNibNamed("RainCloudView", owner: self,options: nil)?.first as? RainCloud {
                for _ in 1...neededLayers {
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
                rainView.dropletsCenter.alpha = 0
                
                // CABasicAnimation uses a single key frame and interpolates equally from
                // the `fromValue` to the `toValue` over the `duration`
                let translation = CABasicAnimation(keyPath: "position")
                translation.duration = 5
                translation.fromValue = NSValue(cgPoint: rainView.dropletsTop.center)
                translation.toValue = NSValue(cgPoint: rainView.dropletsCenter.center)
                
                // CAKeyFrameAnimation allows to define custom keyframe intervals and values
                // The 'keyTime` is an array which contains the progress of the animation time! (0-1)
                // The 'values` is an array with the values of the animation,
                // they are assigned to the `keytimes` indices 1:1
                let opacity = CAKeyframeAnimation(keyPath: "opacity")
                opacity.duration = 10
                opacity.values = 	[0, 0.5, 1]
                opacity.keyTimes = 	[0, 1, 2]
                
                rainView.dropletsTop.layer.add(opacity, forKey: "opacity")
                rainView.dropletsTop.layer.add(translation, forKey: "position")
            }
		}
	}
	
	// -- Rain with UIView.animate()
	private func displayRainUiView() {
        for _ in 1...neededLayers {
		if let rainView = Bundle.main.loadNibNamed("RainCloudView", owner: self, options: nil)?.first as? RainCloud {
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
