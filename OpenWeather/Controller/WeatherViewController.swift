//
//  WeatherViewController.swift
//  OpenWeather
//
//  Created by sindija.dzintare on 18/09/2020.
//  Copyright © 2020 sindija.dzintare. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    
    let weatherDataModel = WeatherDataModel()
    let locationManager = CLLocationManager()
    
    @IBOutlet var weatherIcon: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    //MARK: Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            print("Longitude:  \(location.coordinate.longitude) , Latitude: \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
        
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": weatherDataModel.apiID]
            getWeatherData(url: weatherDataModel.apiUrl, parameters: params)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Err:",error)
        cityLabel.text = "Weather unavailable ☹️"
    }
    
//MARK: Networking
    func getWeatherData(url: String, parameters: [String: String]){
        
        AF.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.value != nil {
                print("Got weather data")
                let weatherJSON: JSON = JSON(response.value!)
                print("weatherJSON: ", weatherJSON)
            
                self.updateWeatherData(json: weatherJSON)
            
            }else{
                print("Err \(String(describing: response.error))")
                self.cityLabel.text = "Connection Issues ☹️"
            }
        }
    }
    
    //MARK: - JSON Parsing with SwiftlyJSON
    
    func updateWeatherData(json: JSON){
        
        if let tempResult = json["main"]["temp"].double{
            weatherDataModel.temp = Int(tempResult - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
            
        }else{
            self.cityLabel.text = "Connection Issues ☹️"
        }
        
    }
    
     //MARK: - Update UI
    func updateUIWithWeatherData(){
        
        cityLabel.text = weatherDataModel.city
        tempLabel.text = "\(weatherDataModel.temp) º"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    //MARK: - ChangeCityDelegate Delegate
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
        let destinationVC = segue.destination as! ChangeCityViewController
        destinationVC.delegate = self
    }
    }
    
    func userEnteredNewCityName(city: String) {
     print(city)
    }
}

