//
//  ViewController.swift
//  weatherApp
//
//  Created by Samieh Sadeghi on 2020-02-12.
//  Copyright © 2020 Samieh Sadeghi. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
  
    @IBOutlet var iconImgView: UIImageView!
    @IBOutlet var minMaxTempLabel: UILabel!
    var apId:String="66a30c555a6df8f344653385a12fa8a0"
    var defaultCity=UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set background setting
        displayBg()
        //animate view elements
        animateElements()
        
        var str=defaultCity.string(forKey: "defaultCity")
        
        
        getWeatherData(_stringCity: str ?? "stockholm"){(temp,desc,icon,name,dblMin,dblMax,dblLon,dblLat) in
            self.cityLabel.text=name
            self.tempLabel.text="\(Int(temp))℃"
            self.descLabel.text=desc
            self.minMaxTempLabel.text="\(Int(dblMin))°"+"/"+"\(Int(dblMax))°"
            self.downloadWeatherIcon(iconId: icon, completion: {(data) in
            self.iconImgView.image=UIImage(data: data)
                
            })
            self.getTimezoneId(lat: dblLat, lng: dblLon) { (timeZoneId) in
                self.dateLabel.text=self.dateFromLocation(identifier: timeZoneId)
                self.timeLabel.text=self.timeFromLocation(identifier: timeZoneId)
            }
                
            }
        }
           

//Background setting
    func displayBg(){
        self.navigationController?.isToolbarHidden=false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),for: .default)
        self.navigationController?.navigationBar.shadowImage=UIImage()
        self.navigationController?.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .bottom, barMetrics: .default)
        self.navigationController?.toolbar.shadowImage(forToolbarPosition: .bottom)
        self.navigationController?.toolbar.isTranslucent=true
        let img=UIImageView(image: UIImage(named: "bg1.jpg"))
        img.frame=view.frame
        img.contentMode = .scaleAspectFill
        self.view.addSubview(img)
        self.view.sendSubviewToBack(img)
        
        }
    
    
    //Get data information from API
    func getWeatherData(_stringCity:String,completion:@escaping( _ weather:Double, _ desc:String,  _ icon:String, _ name:String, _ min:Double, _ max:Double, _ lon:Double, _ lat:Double)->()){
        let cityFiltered:String=_stringCity.replacingOccurrences(of: " ", with: "+")
        //print(cityFiltered)
        let url:URL=URL(string:"https://api.openweathermap.org/data/2.5/weather?q=\(cityFiltered)&appid=\(apId)")!
       //print(url)
        
        let task=URLSession.shared.dataTask(with: url) { (data,response,error) in
            
            if error==nil
            {
                if let dataValid=data
                {
                    do{
                        let jsonDic=try JSONSerialization.jsonObject(with: dataValid, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        
                        //print(jsonDic)
                        let weather=jsonDic.value(forKey: "weather") as! NSArray
                        let weather0=weather[0] as! NSDictionary
                        _=weather0.value(forKey: "main")
                        let name=jsonDic.value(forKey: "name") as! String
                        
                        let description=weather0.value(forKey: "description") as! String
                        let icon=weather0.value(forKey: "icon") as! String
                        let tempDic=jsonDic.value(forKey: "main") as! NSDictionary
                        let currentTemp:Double=tempDic.value(forKey: "temp") as! Double
                        
                        let tempCelciuse=currentTemp-273.15
                        let minTemp:Double=(tempDic.value(forKey: "temp_min") as! Double)-273.15
                        let maxTemp:Double=(tempDic.value(forKey: "temp_max") as! Double)-273.15
                        let coord=jsonDic.value(forKey: "coord") as! NSDictionary
                        let lon=coord.value(forKey: "lon") as! Double
                        let lat=coord.value(forKey: "lat") as! Double
                        //print(coord)
                        //print(tempCelciuse,description,icon,name,minTemp,maxTemp)
                        DispatchQueue.main.async {
                            completion(tempCelciuse,description,icon,name,minTemp,maxTemp,lon,lat)
                        }
                        
                    }catch
                    {
                        print(error.localizedDescription)
                    }
                }//do
            }//if
           
        }//task
        task.resume()
        
        }
    
    func downloadWeatherIcon(iconId:String,completion:@escaping (_ imageData:Data)->()){
        let url:URL = URL(string:"https://openweathermap.org/img/w/\(iconId).png")!
        
        let task=URLSession.shared.dataTask(with:url) { (data,response,error)
            in
            
            if error==nil{
                if let dataok=data{
                    do{
                        DispatchQueue.main.async(execute:{
                            completion(dataok)
                        })
                    }catch{
                        print(error.localizedDescription)
                    }
                }
            }
           
    }//task

    task.resume()
    
}
    
    func getImage(from iconId: String) -> UIImage? {
        //2. Get valid URL
        guard let url = URL(string: "https://openweathermap.org/img/w/\(iconId).png")
            else {
                print("Unable to create URL")
                return nil
        }

        var image: UIImage? = nil
        do {
            //3. Get valid data
            let data = try Data(contentsOf: url, options: [])

            //4. Make image
            image = UIImage(data: data)
        }
        catch {
            print(error.localizedDescription)
        }

        return image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        viewDidLoad()
    }
    
     func animateElements()
     {
        UIView.animate(withDuration: 2.0,delay: 0.5,options: .curveEaseIn,animations:  {
            self.iconImgView.alpha=0.0
            self.tempLabel.alpha=0.0
             self.iconImgView.alpha=1.0
            self.tempLabel.alpha=1.0
            //self.cityLabel.center.y=50
            self.cityLabel.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            self.cityLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        })
      
    }
    
    //update timezone from google API based on default city
    func getTimezoneId(lat:Double,lng:Double, completion:@escaping(_ identifier:String)->())
    {
        
        let key="AIzaSyALrnGtxqBKmvgsmJwwRAcv5OST8AFk1hs"
         let
            url=URL(string:"https://maps.googleapis.com/maps/api/timezone/json?location=\(lat),\(lng)&timestamp=1331161200&key=\(key)")!
        
        var idenitifier:String?
        
        let task=URLSession.shared.dataTask(with:url) { (data,response,error)
                   in
                   
                   if error==nil
                   {
                       if let dataValid=data
                       {
                           do{
                               let jsonDic=try JSONSerialization.jsonObject(with: dataValid, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            idenitifier=jsonDic["timeZoneId"] as! String
                               DispatchQueue.main.async(execute:{
                                   completion(idenitifier!)
                               })
                           }catch{
                               print(error.localizedDescription)
                           }
                       }//if
                   }//if
                  
           }//task

           task.resume()
    }
    //Set date based on timezone to update date label
    func dateFromLocation(identifier:String)->String
    {
        var dateStr:String?
        let currentDate=Date()
        let dateFormatter=DateFormatter()
        dateFormatter.dateFormat="MMMM dd"
        dateFormatter.timeZone=TimeZone(identifier: identifier)
        dateStr=dateFormatter.string(from: currentDate)
        return dateStr!
    }
    //Set time based on timezone to update date label
    func timeFromLocation(identifier:String)->String
    {
        var timeStr:String?
        let currentDate=Date()
             let dateFormatter=DateFormatter()
             dateFormatter.dateFormat="hh:mm a"
             dateFormatter.timeZone=TimeZone(identifier: identifier)
            timeStr=dateFormatter.string(from: currentDate)
        return timeStr!
    }
        
}
            
        




