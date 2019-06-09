//
//  Config.swift
//  Code Test – Get Current Weather
//
//  Created by Santosh Guruju | MACROKIOSK on 09/06/19.
//  Copyright © 2019 workstreak. All rights reserved.
//

import Foundation

class Config {
    
    //Free API was collected from https://openweathermap.org/api
    let APIKey = "appid=ec1f81d7376043d463b1a7d4f50b87fa"
    let weatherURL = "http://api.openweathermap.org/data/2.5/weather?q="
    let requiredMetrics = "&units=metric&"
    
    //function to construct the API URL
    func constructAPI(cityName:String) -> String {
        
        let resultAPI = self.weatherURL + cityName + self.requiredMetrics + self.APIKey
        return resultAPI as String
    }
    
}
