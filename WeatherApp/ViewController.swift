import UIKit
import CoreLocation

class ViewController: UIViewController,  CLLocationManagerDelegate {
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var temperature: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = NSURL(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)")
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(url!) {
            data, response, error in var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            var err: NSErrorPointer = nil
            let json = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments & .MutableLeaves, error: err) as NSDictionary
            if((err) != nil) {
                // println(err!.localizedDescription)
            }
            else {
                self.updateOnSuccess(json)
            }
        }
        task.resume()
    }
    
    func updateOnSuccess(jsonResult: NSDictionary) {
        if let tempResult = ((jsonResult["list"]? as NSArray)[0]["main"] as NSDictionary)["temp"] as? Double {
            var temperature: Double
            var cntry: String
            cntry = ""
            if let city = (jsonResult["city"]? as? NSDictionary) {
                if let country = (city["country"] as? String) {
                    cntry = country
                    if (country == "US") {
                        temperature = round(((tempResult - 273.15) * 1.8) + 32)
                    }
                    else {
                        temperature = round(tempResult - 273.15)
                    }
                    self.temperature.font = UIFont.boldSystemFontOfSize(60)
                    self.temperature.text = "\(temperature)°"
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("toto")
        var location:CLLocation = locations[locations.count-1] as CLLocation
        
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            println(location.coordinate)
            updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
}

