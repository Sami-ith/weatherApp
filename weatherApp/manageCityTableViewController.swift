//
//  manageCityTableViewController.swift
//  weatherApp
//
//  Created by Samieh Sadeghi on 2020-02-17.
//  Copyright © 2020 Samieh Sadeghi. All rights reserved.
//



// This view shows a user's favorite list, user can add new city by + icon and can see a simple bar chart from toolbar icon
//user can delete from table by swap left

import UIKit

class manageCityTableViewController: UITableViewController {

    let defaults = UserDefaults.standard
    var selectedCity:[String]=[]
    var cityTemp:[Double]=[]
    override func viewDidLoad() {
   
    
       tableView.backgroundView = UIImageView(image: UIImage(named: "bg1.jpg"))
        //user city list
        selectedCity=defaults.stringArray(forKey: "selectedCity") ?? [String]()
        tableView.reloadData()
        super.viewDidLoad()
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return selectedCity.count
    }

    //set tables information from a user city list
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
        let cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell
     
        
        
        cell.textLabel?.text=selectedCity[indexPath.row]
        let vc=ViewController()
        vc.getWeatherData(_stringCity: selectedCity[indexPath.row]) {(temp,desc,icon,name,dbl2,dbl3,dbllat,dbllon)  in
            //cell.textLabel?.text=name
            self.cityTemp.append(temp)
            cell.detailTextLabel?.text="\(Int(temp))℃"
            if let image = self.getImage(from: icon) {
                //5. Apply image
                cell.imageView!.image = image
            }
          
        }
        defaults.set(cityTemp, forKey: "cityTemp")
        return cell
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.viewDidLoad()
        
        tableView.reloadData()
        
        
        
        
        
        
    }
    //selected city will save as default, after will back to first view and all elements will update by new information(time,date,city name,icon,temp)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cell = tableView.cellForRow(at: indexPath)
        if cell != nil{
            defaults.set(cell?.textLabel?.text, forKey: "defaultCity")
            defaults.synchronize()
        }
        self.navigationController?.popViewController(animated: true)
        
        
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            selectedCity.remove(at: indexPath.row)
            cityTemp.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            defaults.set(selectedCity, forKey: "selectedCity")
            defaults.set(cityTemp,forKey: "cityTemp")
            defaults.synchronize()
        }
        tableView.reloadData()
    }
    //get image(weather icon) from url by icon name
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
  
 

}
