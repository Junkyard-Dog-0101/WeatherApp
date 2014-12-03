import UIKit
import CoreLocation

class ViewController: UIViewController,  CLLocationManagerDelegate {
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time1: UILabel!
    
    @IBOutlet weak var loading: UILabel!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var time4: UILabel!
    @IBOutlet weak var time3: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var temp4: UILabel!
    @IBOutlet weak var temp3: UILabel!
    @IBOutlet weak var temp2: UILabel!
    @IBOutlet weak var temp1: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let background = UIImage(named: "background_winter.jpg")
        self.view.backgroundColor = UIColor(patternImage: background!)
        let singleFingerTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        self.view.addGestureRecognizer(singleFingerTap)
        loadingIndicator.startAnimating()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
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
        self.loading.text = nil
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        if let tempResult = ((jsonResult["list"]? as NSArray)[0]["main"] as NSDictionary)["temp"] as? Double {
            var temperature: Double
            var cntry: String
            cntry = ""
            if let city = (jsonResult["city"]? as? NSDictionary) {
                if let country = (city["country"] as? String) {
                    cntry = country
 
                    temperature = round(tempResult - 273.15)
                    
                    
                    // FIXED: Is it a bug of Xcode 6? can not set the font size in IB.
                    self.temperature.font = UIFont.boldSystemFontOfSize(60)
                    self.temperature.text = "\(temperature)°"
                }
                
                if let name = (city["name"] as? String) {
                    self.location.font = UIFont.boldSystemFontOfSize(25)
                    self.location.text = name
                }
            }
            
            
            if let weatherArray = (jsonResult["list"]? as? NSArray) {
                for index in 0...4 {
                    if let perTime = (weatherArray[index] as? NSDictionary) {
                        if let main = (perTime["main"]? as? NSDictionary) {
                            var temp = (main["temp"] as Double)
                           
                                // Otherwise, convert temperature to Celsius
                                temperature = round(temp - 273.15)
                            
                            
                            // FIXED: Is it a bug of Xcode 6? can not set the font size in IB.
                            self.temperature.font = UIFont.boldSystemFontOfSize(60)
                            if (index==1) {
                                self.temp1.text = "\(temperature)°"
                            }
                            if (index==2) {
                                self.temp2.text = "\(temperature)°"
                            }
                            if (index==3) {
                                self.temp3.text = "\(temperature)°"
                            }
                            if (index==4) {
                                self.temp4.text = "\(temperature)°"
                            }
                        }
                        var dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "HH:mm"
                        if let date = (perTime["dt"]? as? Double) {
                            let thisDate = NSDate(timeIntervalSince1970: date)
                            let forecastTime = dateFormatter.stringFromDate(thisDate)
                            if (index==1) {
                                self.time1.text = forecastTime
                            }
                            if (index==2) {
                                self.time2.text = forecastTime
                            }
                            if (index==3) {
                                self.time3.text = forecastTime
                            }
                            if (index==4) {
                                self.time4.text = forecastTime
                            }
                        }
                        if let weather = (perTime["weather"]? as? NSArray) {
                            var condition = (weather[0] as NSDictionary)["id"] as Int
                            var icon = (weather[0] as NSDictionary)["icon"] as String
                            var nightTime = false
                            if icon.rangeOfString("n") != nil{
                                nightTime = true
                            }
                            self.updateWeatherIcon(condition, nightTime: nightTime, index: index)
                            if (index==4) {
                                return
                            }
                            
                        }
                    }
                }
            }
        }
        self.loading.text = "Weather info is not available!"
        
    }
    
    
    func updatePictures(index: Int, name: String) {
        if (index==0) {
            self.icon.image = UIImage(named: name)
        }
        if (index==1) {
            self.image1.image = UIImage(named: name)
        }
        if (index==2) {
            self.image2.image = UIImage(named: name)
        }
        if (index==3) {
            self.image3.image = UIImage(named: name)
        }
        if (index==4) {
            self.image4.image = UIImage(named: name)
        }
    }
    
    func updateWeatherIcon(condition: Int, nightTime: Bool, index: Int) {
        // Thunderstorm
        
        var images = [self.icon.image, self.image1.image, self.image2.image, self.image3.image, self.image4.image]
        
        if (condition < 300) {
            if nightTime {
                self.updatePictures(index, name: "tstorm1_night")
            } else {
                self.updatePictures(index, name: "tstorm1")
            }
        }
            // Drizzle
        else if (condition < 500) {
            self.updatePictures(index, name: "light_rain")
            
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            self.updatePictures(index, name: "shower3")
        }
            // Snow
        else if (condition < 700) {
            self.updatePictures(index, name: "snow4")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                self.updatePictures(index, name: "fog_night")
            } else {
                self.updatePictures(index, name: "fog")
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            self.updatePictures(index, name: "tstorm3")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                self.updatePictures(index, name: "sunny_night")
            }
            else {
                self.updatePictures(index, name: "sunny")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                self.updatePictures(index, name: "cloudy2_night")
            }
            else{
                self.updatePictures(index, name: "cloudy2")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            self.updatePictures(index, name: "overcast")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            self.updatePictures(index, name: "tstorm3")
        }
            // Cold
        else if (condition == 903) {
            self.updatePictures(index, name: "snow5")
        }
            // Hot
        else if (condition == 904) {
            self.updatePictures(index, name: "sunny")
        }
            // Weather condition is not available
        else {
            self.updatePictures(index, name: "dunno")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}