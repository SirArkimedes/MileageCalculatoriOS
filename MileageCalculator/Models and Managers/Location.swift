//
//  Location.swift
//  MileageCalculator
//
//  Created by Andrew Robinson on 12/16/17.
//  Copyright © 2017 Andrew Robinson. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class Location {
    static let root = "Locations"

    static let name = "name"
    static let lat = "lat"
    static let lon = "lon"

    var key = ""

    var name = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    var location: CLLocation?

    private var distances = [String: Double]()

    init() { }

    func load(fromDict dict: [String: Any]) -> Location {
        if let n = dict[Location.name] as? String { name = n }
        if let la = dict[Location.lat] as? Double { lat = la }
        if let lo = dict[Location.lon] as? Double { lon = lo }

        location = CLLocation(latitude: lat, longitude: lon)

        for (key, value) in dict {
            if key != Location.name && key != Location.lat && key != Location.lon {
                if let distance = value as? Double {
                    distances[key] = distance
                }
            }
        }

        return self
    }

    func getDistance(from key: String) -> Double {
        return distances[key] ?? 0.0
    }
}
