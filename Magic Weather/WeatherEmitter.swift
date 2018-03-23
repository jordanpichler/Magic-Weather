//
//  WeatherEmitter.swift
//  Magic Weather
//
//  Created by Jordan Pichler on 11/06/2017.
//  Copyright © 2017 Jordan A. Pichler. All rights reserved.
//

import UIKit

enum celltype {
    case snowflakes, clouds, windlines, leaves
}

class WeatherEmitter {
    static func createEmitter(with images: [UIImage], type: celltype, inversed: Bool = false) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterShape = kCAEmitterLayerSphere
        emitter.emitterCells = generateEmitterCells(with: images, inversed: inversed, type: type)
        
        return emitter
    }
    
    static func generateEmitterCells(with images: [UIImage], inversed: Bool, type: celltype) -> [CAEmitterCell] {
        var flakes = [CAEmitterCell]()
        
        switch type {
        case .snowflakes:
            for image in images {
                let flake = CAEmitterCell()
                
                // Configure cell
                flake.contents = image.cgImage
                flake.birthRate = 4
                flake.lifetime = 3
				flake.velocity = CGFloat(100)
                flake.velocityRange = 20
                flake.emissionLongitude = (90 * (.pi / 180))
                flake.emissionRange = (30 * (.pi / 180))
				flake.scale = 0.12
                flake.scaleRange = 0.06
                flake.alphaSpeed = -0.3
				flake.spin = 0.8
                flake.spinRange = 0.2
				flake.redRange = 0.1
                
                // Cell done, append to array
                flakes.append(flake)
            }

        case .clouds:
            for image in images {
                let flake = CAEmitterCell()
            
                flake.contents = image.cgImage
                flake.birthRate = 160
                flake.lifetime = 6
                flake.velocity = CGFloat(15)
                flake.emissionLongitude = (0 * (.pi / 180))
                flake.emissionRange = (10 * (.pi / 180))
                flake.scale = 0.9
                flake.scaleRange = 0.5
                flake.alphaSpeed = -0.20
                flake.alphaRange = 0.1
                flake.velocityRange = 20

                if inversed {
                    flake.emissionLongitude = (180 * (.pi/180))
                }
                flake.spin = 0.8
                flake.spinRange = 0.5
            
                flakes.append(flake)
            }
                case .windlines:
                let flake = CAEmitterCell()
                
                flake.contents = #imageLiteral(resourceName: "line-1").cgImage
                flake.scale = 0.5
                flake.birthRate = 12
                flake.lifetime = 3
                flake.velocity = CGFloat(400)
                flake.emissionLongitude = (0 * (.pi / 180))
                flake.alphaRange = 0.7
                
                flakes.append(flake)
            
        case .leaves:
            for image in images {
                let flake = CAEmitterCell()
                
                flake.contents = image.cgImage
                flake.birthRate = 0.2
                flake.lifetime = 3
                flake.velocity = CGFloat(300)
                flake.emissionLongitude = (0 * (.pi / 180))
                flake.emissionRange = (5 * (.pi / 180))
                flake.scale = 0.12
                flake.scaleRange = 0.06
                flake.velocityRange = 20
                flake.spin = 5
                
                flakes.append(flake)
            }
        }
        
        return flakes
	}
}
