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

class WeatherViewController: UIViewController {

    let weatherManager = WeatherServiceManager()

    @IBOutlet weak var LowHighTemps: UIStackView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var summarayLabel: UILabel!
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
        self.displayCloudy()
    }
    @IBAction func windbutton(_ sender: Any) {
        self.displayWind()
    }
    
    @IBAction func clear(_ sender: Any) {
        self.clearAnimationView()
    }
    
    @IBOutlet var labelForDay: [UILabel]!

    @IBOutlet var iconForDay: [UIImageView]!
    
    var lottieAnimationView: LOTAnimationView?
    
   
    // enum!
    let icons: Dictionary<String, UIImage> = ["clear-day": #imageLiteral(resourceName: "Sun"), "clear-night": #imageLiteral(resourceName: "Sun"), "rain": #imageLiteral(resourceName: "Rain"), "snow": #imageLiteral(resourceName: "snowflake-2"), "cloudy": #imageLiteral(resourceName: "Cloudy"), "fog": #imageLiteral(resourceName: "Cloud"),"partly-cloudy-day": #imageLiteral(resourceName: "PartlyCloudy"), "partly-cloudy-night": #imageLiteral(resourceName: "PartlyCloudy"), "wind": #imageLiteral(resourceName: "Cloud"), "sleet": #imageLiteral(resourceName: "Rain"),]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        summarayLabel.transform = CGAffineTransform(translationX: 30, y: 0)
        temperatureLabel.transform = CGAffineTransform(translationX: 30, y: 0)
        LowHighTemps.transform = CGAffineTransform(translationX: 30, y: 0)
        dayForecastView.transform = CGAffineTransform(translationX: 30, y: 0)

        summarayLabel.alpha = 0
        temperatureLabel.alpha = 0
        LowHighTemps.alpha = 0
        dayForecastView.alpha = 0
        
        dayForecastView.contentSize.width = 580
    }

    @IBAction func onButtonClick(_ sender: Any) {

        let searchCity = "Innsbruck"
        
        weatherManager.downloadWeatherData(for: searchCity) { (result: [Forecast]) in
            DispatchQueue.main.async {
                if let today = result.first {
                self.cityLabel.text = searchCity
                self.temperatureLabel.text = "\(Int(today.temperature.rounded()))°"
                self.summarayLabel.text = today.summary

                self.tempLowLabel.text = "Lo \(Int(today.tempLow!.rounded()))°"
                self.tempHighLabel.text = "Hi \(Int(today.tempHigh!.rounded()))°"
                    
                }
                // Clear Animation View of prior weather animations
                self.clearAnimationView()
                
                // Set up new weather animation
                if let weatherCode = result.first?.identifier {
                    switch weatherCode {
                    case .clearDay, .clearNight, .partlyCloudyDay, .partlyCloudyNight:
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

                    case .fog:
                        print("Fog")
                       self.displayCloudy()

                    case .cloudy:
                        print("Cloudy")
                        self.displaySnow()
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
                        self.summarayLabel.alpha = 1
                        self.summarayLabel.transform = CGAffineTransform(translationX: 0, y: 0)
                    }, completion: nil)

                    UIView.animate(withDuration: 1, delay: 0.4, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [], animations: {
                        self.dayForecastView.alpha = 1
                        self.dayForecastView.transform = CGAffineTransform(translationX: 0, y: 0)
                    }, completion: nil)

                    print("Labels set!")
                }
            }
        }
    
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

    private func clearAnimationView() {
        // Stop UIKit Animations (Sun)
        self.weatherAnimationView.layer.removeAllAnimations()
        self.weatherAnimationView.transform = CGAffineTransform(rotationAngle: 0)
        
        // Remove Subviews (Lottie)
        print("removing subView")
        for view in self.weatherAnimationView.subviews {
            view.removeFromSuperview()
        }
        
        // Remove Sublayers (Clouds/Snow)
        self.weatherAnimationView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    // -- Lottie (Key Frames)
    private func displayRain() {
        summarayLabel.textColor = .rain
        
        lottieAnimationView = LOTAnimationView(name: "rain")
		lottieAnimationView?.contentMode = .scaleAspectFit
        lottieAnimationView?.frame = weatherAnimationView.frame
        lottieAnimationView?.center = CGPoint(x: weatherAnimationView.frame.size.width / 1.5, y: weatherAnimationView.frame.size.height / 2)
        self.weatherAnimationView.addSubview(lottieAnimationView!)
		self.weatherAnimationView.contentMode = .scaleAspectFit

        lottieAnimationView?.loopAnimation = true
        lottieAnimationView?.animationSpeed = 5
        lottieAnimationView?.play()
    }
    
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
        summarayLabel.textColor = .snow
        
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
    
    // -- UIKit Animations
    private func displaySun() {
        summarayLabel.textColor = .sun
        
        let imageAnimationView = UIImageView(image: #imageLiteral(resourceName: "Sun"))
        imageAnimationView.frame = weatherAnimationView.frame
        imageAnimationView.center = CGPoint(x: weatherAnimationView.frame.size.width / 2, y: weatherAnimationView.frame.size.height / 2)
        weatherAnimationView.addSubview(imageAnimationView)
		
        UIView.animate(withDuration: 5,
                       delay: 0.8,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.1,
                       options: [.repeat, .autoreverse, .curveEaseIn],
                       animations: {
                        self.weatherAnimationView.transform = CGAffineTransform(rotationAngle: 130 * (.pi / 180))
                       },
                       completion: nil)
    }

    // -- Lottie
    private func displayWind() {
        summarayLabel.textColor = .windy

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
}

