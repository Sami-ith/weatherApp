//
//  selectCityViewController.swift
//  weatherApp
//
//  Created by Samieh Sadeghi on 2020-02-17.
//  Copyright © 2020 Samieh Sadeghi. All rights reserved.
//

//
import UIKit
struct city:Decodable {
    
    let id:Int
    let name:String
    let country:String
    }

class selectCityViewController: UIViewController{
    var cityArray:[city]=[]
    var filterCity:[city]=[]
    var selectedCity:[String]=[]
    let defaults = UserDefaults.standard
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var searchbar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        //background setting
        setBg()
        //get data weather data from LOCAL JSON
        loadJsonData()
        //a list of cities that were chosen by user
        selectedCity=defaults.stringArray(forKey: "selectedCity") ?? [String]()
        
        
        self.tableview.delegate=self
        self.tableview.dataSource=self
        self.searchbar.delegate=self
        filterCity=cityArray
        
        
    }
    
//get data weather data from LOCAL JSON
    func loadJsonData(){
        
        do {
                   let url=Bundle.main.url(forResource: "city.list", withExtension: "json")
                   let jsondata=try Data(contentsOf:url!)
                   let cities=try JSONDecoder().decode([city].self, from: jsondata)
                   cityArray=cities
           
               } catch let error {
                   print(error)
               }
        
    }
    func setBg(){
        let img=UIImageView(image: UIImage(named: "bg1.jpg"))
        img.frame=view.frame
        img.contentMode = .scaleAspectFill
        self.view.addSubview(img)
        self.view.sendSubviewToBack(img)
    }
}
extension selectCityViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else{
            filterCity=cityArray
            tableview.reloadData()
            return
        }
        filterCity=cityArray.filter({ (city) -> Bool in
            return city.name.contains(searchText)
        })
        tableview.reloadData()
    }
    
}
extension selectCityViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCity.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text=filterCity[indexPath.row].country
        cell?.detailTextLabel?.text=filterCity[indexPath.row].name
        let cityId=filterCity[indexPath.row].id
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        if (cell != nil)
        {
           // print(cell?.detailTextLabel?.text)
            
            selectedCity.append((cell?.detailTextLabel!.text)!)
        }
        defaults.set(selectedCity, forKey: "selectedCity")
        
       
        tableView.reloadData()
        self.viewDidLoad()
        self.parent?.viewDidLoad()
        self.navigationController?.popViewController(animated: true)
    }
    
        
    
}
